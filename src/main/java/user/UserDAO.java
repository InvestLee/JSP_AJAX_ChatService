package user;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;


//회원과 관련한 데이터베이스 접근 및 처리를 담당
//Data Access Object(데이터 접근 객체) : 실질적으로 데이터베이스에 접근해서 어떠한 데이터를 가져오거나 쓰거나 하는 역할 수행
public class UserDAO {

	//Connection pool을 이용하기 위함
	DataSource dataSource;
	
	//객체가 생성되자마자 데이터베이스에 접속할 수 있는 생성자
	public UserDAO() {
		try {
			InitialContext initContext = new InitialContext();
			Context envContext = (Context) initContext.lookup("java:/comp/env"); //소스에 접근 할 수 있도록 하는 기능
			dataSource = (DataSource) envContext.lookup("jdbc/UserChat"); //소스 발견하게 되면 프로젝트 접근
		}catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	//회원 관련 데이버베이스 처리용 메서드
	public int login(String userID, String userPassword) {
		Connection conn = null;
		PreparedStatement pstmt = null; //SQL Injection같은 해킹공격을 방어해주고 안정적으로 SQL문을 실행하게 해줌
		ResultSet rs = null;
		String SQL = "SELECT * FROM USER WHERE userID = ?"; //입력받은 그 값을 넣어줌
		try {
			//getConnection() : 실질적으로 데이터베이스 Connection pool에 접근하도록 만들어 줌
			conn = dataSource.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, userID);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				//사용자가 입력한 암호과 데이터 베이스 상 암호가 일치한다면 
				if(rs.getString("userPassword").equals(userPassword)) {
					return 1; //로그인 성공
				}
				return 2; //비밀번호가 틀림
			} else {
				return 0; //해당 사용자가 존재하지 않음
			}
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			try {
				if(rs != null) rs.close();
				if(pstmt != null) pstmt.close();
				if(conn != null) conn.close();
			}catch(Exception e) {
				e.printStackTrace();
			}
		}
		return -1; //데이터 베이스 오류가 발생한 경우 
	}
	
	//가입 가능 여부 체크
	public int registerCheck(String userID) {
		Connection conn = null;
		PreparedStatement pstmt = null; //SQL Injection같은 해킹공격을 방어해주고 안정적으로 SQL문을 실행하게 해줌
		ResultSet rs = null;
		String SQL = "SELECT * FROM USER WHERE userID = ?"; //입력받은 그 값을 넣어줌
		try {
			//getConnection() : 실질적으로 데이터베이스 Connection pool에 접근하도록 만들어 줌
			conn = dataSource.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, userID);
			rs = pstmt.executeQuery();
			if(rs.next() || userID.equals("")) {
				return 0; //이미 존재하는 회원
			} else {
				return 1; //가입 가능한 회원 아이디
			}
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			try {
				if(rs != null) rs.close();
				if(pstmt != null) pstmt.close();
				if(conn != null) conn.close();
			}catch(Exception e) {
				e.printStackTrace();
			}
		}
		return -1; //데이터 베이스 오류가 발생한 경우 
	}
	
	public int register(String userID, String userPassword, String userName, String userAge, String userGender, String userEmail, String userProfile) {
		Connection conn = null;
		PreparedStatement pstmt = null; //SQL Injection같은 해킹공격을 방어해주고 안정적으로 SQL문을 실행하게 해줌
		String SQL = "INSERT INTO USER VALUES (?, ?, ?, ?, ?, ?, ?)"; //입력받은 그 값을 넣어줌
		try {
			//getConnection() : 실질적으로 데이터베이스 Connection pool에 접근하도록 만들어 줌
			conn = dataSource.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, userID);
			pstmt.setString(2, userPassword);
			pstmt.setString(3, userName);
			pstmt.setInt(4, Integer.parseInt(userAge)); //숫자 형태가 아닌 문자 형태가 들어오는 경우 return -1 오류 처리
			pstmt.setString(5, userGender);
			pstmt.setString(6, userEmail);
			pstmt.setString(7, userProfile);
			return pstmt.executeUpdate();
			//rs = pstmt.executeQuery(); executeQuery()는 데이터를 가져올 때 사용 insert랑 맞지 않음
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			try {
				if(pstmt != null) pstmt.close();
				if(conn != null) conn.close();
			}catch(Exception e) {
				e.printStackTrace();
			}
		}
		return -1; //데이터 베이스 오류가 발생한 경우 
	}
}
