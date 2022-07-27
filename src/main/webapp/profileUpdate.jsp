<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="user.UserDTO" %>
<%@ page import="user.UserDAO" %>
<!DOCTYPE html>
<html>
	<!-- 세션 작업 -->
	<%
		String userID = null;
		if (session.getAttribute("userID") != null){
			userID = (String) session.getAttribute("userID");
		} //유저 ID 세션 값이 비어있지 않다면 특정한 사람의 아이디 값을 가져와서 접속 유무를 판단
		if(userID==null){
			session.setAttribute("messageType", "오류 메시지");
			session.setAttribute("messageContent", "현재 로그인이 되어 있지 않습니다.");
			response.sendRedirect("index.jsp");
			return;
		}
		UserDTO user = new UserDAO().getUser(userID);
	%>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="css/bootstrap.css">
	<link rel="stylesheet" href="css/custom.css">
	<title>JSP AJAX로 만든 이지형 채팅 서비스</title>
	<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
	<script src="js/bootstrap.js"></script>
	<script type="text/javascript">
		function getUnread(){
			$.ajax({
				type: 'POST',
				url: './chatUnread',
				data: {
					userID: encodeURIComponent('<%= userID %>'),
				}, //{속성명: 값}
				success: function(result){
					if(result >= 1){
						showUnread(result);
					} else {
						showUnread('');
					}
				}
			});
		}
		function getInfiniteUnread() {
			setInterval(function() {
				getUnread(); 
			}, 4000);
		}
		function showUnread(result){
			$('#unread').html(result); //unread라는 id값을 가지는 원소에 매개변수 result를 넣음
		}
		function passwordCheckFunction(){
			var userPassword1 = $('#userPassword1').val();
			var userPassword2 = $('#userPassword2').val();
			if(userPassword1 != userPassword2){
				$('#passwordCheckMessage').html('비밀번호가 서로 일치하지 않습니다.');
			}else{
				$('#passwordCheckMessage').html('');
			}
		}
	</script>
</head>
<body>
	<nav class="navbar navbar-default">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse" data-target="#bs-example-navbar-collapse-1"
				aria-expanded="false">
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="index.jsp">JSP AJAX로 만든 이지형 채팅 서비스</a>
		</div>
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li><a href="index.jsp">메인</a>
				<li><a href="find.jsp">이용자 찾기</a></li>
				<li><a href="box.jsp">메시지함<span id="unread" class="label label-info"></span></a></li> <!-- 라벨을 통해 안읽은 메시지 수 표시 -->
			</ul>
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">회원관리<span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="update.jsp">회원정보 수정</a></li>
						<li class="active"><a href="profileUpdate.jsp">프로필 수정</a></li>
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					</ul>
				</li>
			</ul>
		</div>
	</nav>
	<div class="container">
		<!-- post방식은 데이터를 송신한 때 데이터가 실제로 드러나지 않도록 하여 기본적인 보안 유지 -->
		<!-- enctype="multipart/form-data" 파일 전송을 위한 명령어(전송하는 데이터 양식 : form-data) -->
		<form method="post" action="./userProfile" enctype="multipart/form-data">
			<table class="table table-bordered table-hover" style="text-align: center; border: 1px solid #ddddd">
				<thead>
					<tr>
						<th colspan="3"><h4>프로필 사진 수정 양식</h4></th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td style="width: 110px;"><h5>아이디</h5></td>
						<td><h5><%= user.getUserID() %></h5>
						<input type="hidden" name="userID" value="<%= user.getUserID()%>"></td>
					</tr>
					<tr>
						<td style="width: 110px;"><h5>사진 업로드</h5></td>
						<td colspan="2">
							<input type="file" name="userProfile" class="file">
							<div class="input-group col-xs-12">
								<span class="input-group-addon"><i class="glyphicon glyphicon-picture"></i></span>
								<input type="text" class="form-control input-lg" disabled placeholder="이미지를 업로드하세요.">
								<span class="input-group-btn">
									<button class="browse btn btn-primary input-lg" type="button"><i class="glyphicon glyphicon-search"></i>파일 찾기</button>
								</span>
							</div>
						</td>
					</tr>
					<tr>
						<td style="text-align: left;" colspan="3"><h5 style="color: red;"></h5><input class="btn btn-primary pull-right" type="submit" value="수정"></td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
	
	<%
		//modal
		String messageContent = null;
		if (session.getAttribute("messageContent") != null){
			messageContent = (String) session.getAttribute("messageContent");
		}
		String messageType = null;
		if (session.getAttribute("messageType") != null){
			messageType = (String) session.getAttribute("messageType");
		}
		if (messageContent != null){
	%>
	<div class="modal fade" id="messageModal" tabindex="-1" role="dialog" aria-hidden="true">
		<div class="vertical-alignment-helper">
			<div class="modal-dialog vertical-align-center">
				<div class="modal-content <% if(messageType.equals("오류 메시지")) out.println("panel-warning"); else out.println("panel-success"); %>">
					<div class="modal-header panel-heading">
						<button type="button" class="close" data-dismiss="modal">
							<span aria-hidden="true">&times</span> <!-- x버튼에 해당하는 그림 문자 -->
							<span class="sr-only">Close</span>
						</button>
						<h4 class="modal-title">
							<%= messageType %>
						</h4>
					</div>
					<div class="modal-body">
						<%= messageContent %>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-primary" data-dismiss="modal">확인</button>
					</div>
				</div>
			</div>
		</div>
	</div>
	<%
		//서버로부터 받은 세션 값을 파기
		session.removeAttribute("messageContent");
		session.removeAttribute("messageType");
		}
	%>
	<script>
		//modal창이 사용자한테 보여줄 수 있도록 하는 기능
		$('#messageModal').modal("show");
	</script>
	<% 
		if(userID != null){
	%>
		<script type="text/javascript">
			$(document).ready(function(){
				getUnread();
				getInfiniteUnread();
			});
		</script>
	<%
		}
	%>
	<script type="text/javascript">
		//파일 찾기		
		$(document).on('click', '.browse', function(){
			var file = $(this).parent().parent().parent().find('.file');
			file.trigger('click');
		});
		//파일 교체(파일 클래스 값이 변경되었다면 form-control의 값을 변경함으로써 가시적으로 보여줌)
		$(document).on('change', '.file', function(){
			$(this).parent().find('.form-control').val($(this).val().replace(/C:\\fakepath\\/i, '')); //파일명만 보여주기 위한 /C:\\fakepath\\/i, ''
		});
	</script>
</body>
</html>