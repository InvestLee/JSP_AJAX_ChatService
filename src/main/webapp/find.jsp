<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
	<!-- 세션 작업 -->
	<%
		String userID = null;
		if (session.getAttribute("userID") != null){
			userID = (String) session.getAttribute("userID");
		} //유저 ID 세션 값이 비어있지 않다면 특정한 사람의 아이디 값을 가져와서 접속 유무를 판단
		if (userID == null) {
			session.setAttribute("messageType", "오류 메시지");
			session.setAttribute("messageContent", "현재 로그인이 되어있지 않습니다.");
			response.sendRedirect("index.jsp");
			return;
		}
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
		function findFunction(){
			var userID = $('#findID').val(); //HTML에서 userID의 값 가져오기
			//AJAX를 이용한 비동기 통신
			$.ajax({
				type: 'POST',
				url: './UserRegisterCheckServlet',
				data: {userID: userID}, //{속성명: 값}
				success: function(result){
					if(result == 0){
						$('#checkMessage').html('이용자를 찾았습니다.');
						$('#checkType').attr('class', 'modal-content panel-success'); //속성변경 (변경전, 변경후)
						getFriend(userID);
					} else {
						$('#checkMessage').html('이용자를 찾을 수 없습니다.');
						$('#checkType').attr('class', 'modal-content panel-warning'); //속성변경 (변경전, 변경후)
						failFriend();
					}
					$('#checkModal').modal("show"); //부트스트랩 modal이 눈에 보이도록 함
				}
			});
		}
		function getFriend(findID){
			$('#friendResult').html('<thead>' +
					'<tr>' +
					'<th><h4>검색 결과</h4></th>' +
					'</tr>' + 
					'</thead>' +
					'<tbody>' +
					'<tr>' +
					'<td style="text-align: center;"><h3>' + findID + '</h3><a href="chat.jsp?toID=' + encodeURIComponent(findID) + '" class="btn btn-primary pull-right">' + '메시지 보내기</a></td>' +
					'</tr>' +
					'</tbody>');
		}
		function failFriend(findID){
			$('#friendResult').html('')
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
				<li class="active"><a href="find.jsp">이용자 찾기</a></li>
				<li><a href="box.jsp">메시지함<span id="unread" class="label label-info"></span></a></li> <!-- 라벨을 통해 안읽은 메시지 수 표시 -->
			</ul>
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">회원관리<span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					</ul>
				</li>
			</ul>
		</div>
	</nav>
	<div class="container">
		<table class="table table-bordered table-hover" style="text-align: center; border: 1px solid #dddddd">
			<thead>
				<tr>
					<th colspan="2"><h4>사용자 검색</h4></th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td style="width: 110px;"><h5>찾을 아이디</h5></td>
					<td><input class="form-control" type="text" id="findID" maxlength="20" placeholder="찾을 아이디를 입력하세요."></td>
				</tr>
				<tr>
					<td colspan="2"><button class="btn btn-primary pull-right" onclick="findFunction();">검색</button></td>
				</tr>
			</tbody>
		</table>
	</div>
	<div class="container">
		<table id="friendResult" class="table table-bordered table-hover" style="text-align: center; border: 1px solid #dddddd">
		</table>
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
	<script>
		//modal창이 사용자한테 보여줄 수 있도록 하는 기능
		$('#messageModal').modal("show");
	</script>
	<%
		//서버로부터 받은 세션 값을 파기
		session.removeAttribute("messageContent");
		session.removeAttribute("messageType");
		}
	%>
	<div class="modal fade" id="checkModal" tabindex="-1" role="dialog" aria-hidden="true">
		<div class="vertical-alignment-helper">
			<div class="modal-dialog vertical-align-center">
				<div id="checkType" class="modal-content panel-info"> <!-- 정보를 나타내는 팝업 창 -->
					<div class="modal-header panel-heading">
						<button type="button" class="close" data-dismiss="modal">
							<span aria-hidden="true">&times</span> <!-- x버튼에 해당하는 그림 문자 -->
							<span class="sr-only">Close</span>
						</button>
						<h4 class="modal-title">
							확인 메시지
						</h4>
					</div>
					<div id="checkMessage" class="modal-body">
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-primary" data-dismiss="modal">확인</button>
					</div>
				</div>
			</div>
		</div>
	</div>
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
</body>
</html>