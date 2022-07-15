<html>
<head>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.InitialContext, javax.naming.Context" %>
</head>
<body>
	<%
		//Connection tool 접근을 위함
		InitialContext initCtx = new InitialContext();
		Context envContext = (Context) initCtx.lookup("java:/comp/env"); //initCtx를 중심으로 리소스를 찾을 수 있게 하는 기능
		DataSource ds = (DataSource) envContext.lookup("jdbc/UserChat"); //소스 발견하게 되면 프로젝트 접근
		Connection conn = ds.getConnection(); //커넥션 객체를 이용해서 실제로 데이터 베이스(Context.xml의 url)에 접근할 수 있도록 함
		Statement stmt = conn.createStatement(); //실제 SQL의 어떤 값을 데이터 베이스에 입력한 후 그 결과를 반환하는 역할
		ResultSet rset = stmt.executeQuery("SELECT VERSION();"); //mySQL버전을 도출하여 rset 저장
		while(rset.next()){
			out.println("MySQL Version: " + rset.getString("version()"));
		}
		rset.close(); //만들었던 모든 객체를 close하여 사용하지 않도록 함
		stmt.close();
		conn.close();
		initCtx.close();
	%>
</body>
</html>