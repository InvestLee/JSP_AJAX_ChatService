<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="user.UserDAO" %>
<!DOCTYPE html>
<html>
<head>
	<!-- 세션 작업 -->
	<%
		String userID = null;
		if (session.getAttribute("userID") != null){
			userID = (String) session.getAttribute("userID");
		} //유저 ID 세션 값이 비어있지 않다면 특정한 사람의 아이디 값을 가져와서 접속 유무를 판단
		String toID = null;
		if (request.getParameter("toID") != null){
			toID = (String) request.getParameter("toID");
		}
		if (userID == null) {
			session.setAttribute("messageType", "오류 메시지");
			session.setAttribute("messageContent", "현재 로그인이 되어 있지 않습니다.");
			response.sendRedirect("index.jsp");
			return;
		}
		if (toID == null) {
			session.setAttribute("messageType", "오류 메시지");
			session.setAttribute("messageContent", "대화 상대가 지정되지 않았습니다.");
			response.sendRedirect("index.jsp");
			return;
		}
		if (userID.equals(URLDecoder.decode(toID, "UTF-8"))) {
			session.setAttribute("messageType", "오류 메시지");
			session.setAttribute("messageContent", "자기 자신은 대화상대로 지정할 수 없습니다.");
			response.sendRedirect("index.jsp");
			return;
		}
		String fromProfile = new UserDAO().getProfile(userID);
		String toProfile = new UserDAO().getProfile(toID);
	%>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="css/bootstrap.css">
	<link rel="stylesheet" href="css/custom.css">
	<title>JSP AJAX로 만든 이지형 채팅 서비스</title>
	<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
	<script src="js/bootstrap.js"></script>
	<!-- 메시지 전송 자바스크립트 -->
	<script type="text/javascript">
		function autoClosingAlert(selector, delay){
			var alert = $(selector).alert();
			alert.show();
			window.setTimeout(function() { alert.hide() }, delay);//delay시간만큼만 메시지 보여줌
		}
		function submitFunction(){
			var fromID = '<%= userID %>';
			var toID = '<%= toID %>';
			var chatContent = $('#chatContent').val();
			$.ajax({
				type: 'POST',
				url: './chatSubmitServlet',
				data: {
					fromID: encodeURIComponent(fromID),
					toID: encodeURIComponent(toID),
					chatContent: encodeURIComponent(chatContent)
				}, //{속성명: 값}
				success: function(result) {
					if(result == 1){
						autoClosingAlert('#successMessage', 2000);
						chatListFunction('0'); //전송 성공 시 즉시 갱신
					} else if(result == 0) {
						autoClosingAlert('#dangerMessage', 2000);
					} else {
						autoClosingAlert('#warningMessage', 2000);
					}
				}
			});
			$('#chatContent').val(''); //submit function이 실행되었을 경우 성공하든 실패하든 값을 비워줌
		}
		var lastID = 0;
		function chatListFunction(type) {
			var fromID = '<%= userID %>';
			var toID = '<%= toID %>';
			$.ajax({
				type: 'POST',
				url: './chatListServlet',
				data: {
					fromID: encodeURIComponent(fromID),
					toID: encodeURIComponent(toID),
					listType: type
				}, //{속성명: 값}
				success: function(data) {
					if(data == "") return; 
					var parsed = JSON.parse(data);
					var result = parsed.result;
					for(var i = 0; i < result.length; i++) {
						if(result[i][0].value == fromID){
							result[i][0].value += '(Me)';
						}
						addChat(result[i][0].value, result[i][2].value, result[i][3].value);
					}
					lastID = Number(parsed.last); //마지막 대화의 ID
				}
			});
		}
		function addChat(chatName, chatContent, chatTime) {
			if(chatName == "<%= userID %>" + '(Me)') {
				$('#chatList').append('<div class="row">' +
					'<div class="col-lg-12">' +
					'<div class="media">' +
					'<img class="media-object img-circle" style="width: 30px; height: 30px;" src="<%= fromProfile %>" alt="">' +
					'</a>' +
					'<div class="media-body">' +
					'<h4 class="media-heading">' +
					chatName +
					'<span class="small pull-right">' + 
					chatTime +
					'</span>' +
					'</h4>' +
					'<p>' +
					chatContent +
					'</p>' +
					'</div>' +
					'</div>' +
					'</div>' +
					'</div>' +
					'<hr>');
			} else {
				$('#chatList').append('<div class="row">' +
						'<div class="col-lg-12">' +
						'<div class="media">' +
						'<img class="media-object img-circle" style="width: 30px; height: 30px;" src="<%= toProfile %>" alt="">' +
						'</a>' +
						'<div class="media-body">' +
						'<h4 class="media-heading">' +
						chatName +
						'<span class="small pull-right">' + 
						chatTime +
						'</span>' +
						'</h4>' +
						'<p>' +
						chatContent +
						'</p>' +
						'</div>' +
						'</div>' +
						'</div>' +
						'</div>' +
						'<hr>');
			}
			$('#chatList').scrollTop($('#chatList')[0].scrollHeight); //chatList의 스크롤을 가장 아래쪽으로 내려줌으로써 메시지 올때마다 확인 가능
		}
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
		function getInfiniteChat() {
			setInterval(function() {
				chatListFunction(lastID); //chatListFunction이 1초에 한번 씩 계속 실행될 수 있도록 하는 기능
			}, 1000);
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
				<li><a href="find.jsp">이용자 찾기</a></li>
				<li><a href="box.jsp">메시지함<span id="unread" class="label label-info"></span></a></li> <!-- 라벨을 통해 안읽은 메시지 수 표시 -->
			</ul>
			<%
				if(userID != null) {
			%>
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">회원관리<span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="update.jsp">회원정보 수정</a></li>
						<li><a href="profileUpdate.jsp">프로필 수정</a></li>
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					</ul>
				</li>
			</ul>
			<%
				}
			%>
		</div>
	</nav>
	<div class="container bootstrap snippet">
		<div class="row">
			<div class="col-xs-12">
				<div class="portlet portlet-default">
					<div class="portlet-heading">
						<div class="portlet-title">
							<h4><i class="fa fa-circle text-green"></i>채팅창</h4>
						</div>
						<div class="clearfix"></div>
					</div>
					<div id="chat" class="panel-collapse collapse in">
						<div id="chatList" class="portlet-body chat-widget" style="overflow-y: auto; width: auto; height: 600px;">
						</div>
						<div class="portlet-footer">
							<div class="row" style="height: 90px;">
								<div class="form-group col-xs-10">
									<textarea style="height: 80px;" id="chatContent" class="form-control" placeholder="메시지를 입력하세요" maxlength="100"></textarea>
								</div>
								<div class="form-group col-xs-2">
									<!-- class="btn btn-default pull-right" : 우측 정렬 -->
									<button type="button" class="btn btn-default pull-right" onclick="submitFunction();">전송</button>
									<div class="clearfix"></div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="alert alert-success" id="successMessage" style="display: none;">
		<strong>메시지를 전송했습니다.</strong>
	</div>
	<div class="alert alert-danger" id="dangerMessage" style="display: none;">
		<strong>이름과 내용을 모두 입력해주세요.</strong>
	</div>
	<div class="alert alert-warning" id="warningMessage" style="display: none;">
		<strong>데이터베이스 오류가 발생했습니다.</strong>
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
	<script type="text/javascript">
		$(document).ready(function() {
			getUnread();
			chatListFunction('0');
			getInfiniteChat();
			getInfiniteUnread();
		});
	</script>
</body>
</html>