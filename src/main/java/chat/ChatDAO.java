package chat;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class ChatDAO {
		
		//Connection pool을 이용하기 위함
		DataSource dataSource;
		
		//객체가 생성되자마자 데이터베이스에 접속할 수 있는 생성자
		public ChatDAO() {
			try {
				InitialContext initContext = new InitialContext();
				Context envContext = (Context) initContext.lookup("java:/comp/env"); //소스에 접근 할 수 있도록 하는 기능
				dataSource = (DataSource) envContext.lookup("jdbc/UserChat"); //소스 발견하게 되면 프로젝트 접근
			}catch(Exception e) {
				e.printStackTrace();
			}
		}
		
		//특정 ID에 따른 채팅 내역 get
		public ArrayList<ChatDTO> getChatListByID(String fromID, String toID, String chatID){
			ArrayList<ChatDTO> chatList = null;
			Connection conn = null;
			PreparedStatement pstmt = null; //SQL Injection같은 해킹공격을 방어해주고 안정적으로 SQL문을 실행하게 해줌
			ResultSet rs = null;
			String SQL = "SELECT * FROM CHAT WHERE ((fromID = ? AND toID = ?) OR (fromID = ? AND toID = ?)) AND chatID > ? ORDER BY chatTime";
			try {
				conn = dataSource.getConnection();
				pstmt = conn.prepareStatement(SQL);
				pstmt.setString(1, fromID);
				pstmt.setString(2, toID);
				pstmt.setString(3, toID);
				pstmt.setString(4, fromID);
				pstmt.setInt(5, Integer.parseInt(chatID));
				rs = pstmt.executeQuery();
				chatList = new ArrayList<ChatDTO>();
				while (rs.next()) {
					ChatDTO chat = new ChatDTO();
					chat.setChatID(rs.getInt("chatID"));
					//SQL injection, cross site scripting 공격 등에 대해 방어하기 위해 특수문자 치환
					chat.setFromID(rs.getString("fromID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>")); 
					chat.setToID(rs.getString("toID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
					chat.setChatContent(rs.getString("chatContent").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
					int chatTime = Integer.parseInt(rs.getString("chatTime").substring(11, 13));
					String timeType = "오전";
					if (chatTime == 12) {
						timeType = "오후";
					}
					else if(chatTime > 12) {
						timeType = "오후";
						chatTime -= 12;
					}
					chat.setChatTime(rs.getString("chatTime").substring(0, 11) + " " + timeType + " " + chatTime + ":" + rs.getString("chatTime").substring(14, 16) + "");
					chatList.add(chat);
				}
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if(rs != null) rs.close();
					if(pstmt != null) pstmt.close();
					if(conn != null) conn.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return chatList; //리스트 반환
		}
		
		//최근 대화 내용 반환
		public ArrayList<ChatDTO> getChatListByRecent(String fromID, String toID, int number){
			ArrayList<ChatDTO> chatList = null;
			Connection conn = null;
			PreparedStatement pstmt = null; //SQL Injection같은 해킹공격을 방어해주고 안정적으로 SQL문을 실행하게 해줌
			ResultSet rs = null;
			String SQL = "SELECT * FROM CHAT WHERE ((fromID = ? AND toID = ?) OR (fromID = ? AND toID = ?) AND chatID > (SELECT MAX(chatID) - ? FROM CHAT WHERE (fromID = ? AND toID = ?) OR (fromID = ? AND toID = ?)) ORDER BY chatTime";
			try {
				conn = dataSource.getConnection();
				pstmt = conn.prepareStatement(SQL);
				pstmt.setString(1, fromID);
				pstmt.setString(2, toID);
				pstmt.setString(3, toID);
				pstmt.setString(4, fromID);
				pstmt.setInt(5, number);
				pstmt.setString(6, fromID);
				pstmt.setString(7, toID);
				pstmt.setString(8, toID);
				pstmt.setString(9, fromID);
				rs = pstmt.executeQuery();
				chatList = new ArrayList<ChatDTO>();
				while (rs.next()) {
					ChatDTO chat = new ChatDTO();
					chat.setChatID(rs.getInt("chatID"));
					//SQL injection, cross site scripting 공격 등에 대해 방어하기 위해 특수문자 치환
					chat.setFromID(rs.getString("fromID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>")); 
					chat.setToID(rs.getString("toID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
					chat.setChatContent(rs.getString("chatContent").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
					int chatTime = Integer.parseInt(rs.getString("chatTime").substring(11, 13));
					String timeType = "오전";
					if (chatTime == 12) {
						timeType = "오후";
					}
					else if(chatTime > 12) {
						timeType = "오후";
						chatTime -= 12;
					}
					chat.setChatTime(rs.getString("chatTime").substring(0, 11) + " " + timeType + " " + chatTime + ":" + rs.getString("chatTime").substring(14, 16) + "");
					chatList.add(chat);
				}
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if(rs != null) rs.close();
					if(pstmt != null) pstmt.close();
					if(conn != null) conn.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return chatList; //리스트 반환
		}
		
		//전송 기능(성공 여부 파악을 위한 int)
		public int submit(String fromID, String toID, String chatContent){
			Connection conn = null;
			PreparedStatement pstmt = null; //SQL Injection같은 해킹공격을 방어해주고 안정적으로 SQL문을 실행하게 해줌
			ResultSet rs = null;
			String SQL = "INSERT INTO CHAT VALUES (NULL, ?, ?, ?, NOW(), 0)"; //NULL 값으로 chatID가 1씩 증가
			try {
				conn = dataSource.getConnection();
				pstmt = conn.prepareStatement(SQL);
				pstmt.setString(1, fromID);
				pstmt.setString(2, toID);
				pstmt.setString(3, chatContent);
				return pstmt.executeUpdate(); //1이 반환되고 SQL문이 실행됨
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if(rs != null) rs.close();
					if(pstmt != null) pstmt.close();
					if(conn != null) conn.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return -1; //데이터베이스 오류
		}
		
		public int readchat(String fromID, String toID) {
			Connection conn = null;
			PreparedStatement pstmt = null; //SQL Injection같은 해킹공격을 방어해주고 안정적으로 SQL문을 실행하게 해줌
			ResultSet rs = null;
			String SQL = "UPDATE CHAT SET chatRead = 1 WHERE (fromID = ? AND toID = ?)";
			try {
				conn = dataSource.getConnection();
				pstmt = conn.prepareStatement(SQL);
				pstmt.setString(1, toID);
				pstmt.setString(2, fromID);
				return pstmt.executeUpdate(); //1이 반환되고 SQL문이 실행됨
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if(rs != null) rs.close();
					if(pstmt != null) pstmt.close();
					if(conn != null) conn.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return -1; //데이터베이스 오류
		}
		
		public int getAllUnreadChat(String userID) {
			Connection conn = null;
			PreparedStatement pstmt = null; //SQL Injection같은 해킹공격을 방어해주고 안정적으로 SQL문을 실행하게 해줌
			ResultSet rs = null;
			String SQL = "SELECT COUNT(chatID) FROM CHAT WHERE toID = ? AND chatRead = 0";
			try {
				conn = dataSource.getConnection();
				pstmt = conn.prepareStatement(SQL);
				pstmt.setString(1, userID);
				rs = pstmt.executeQuery();
				if(rs.next()) {
					return rs.getInt("COUNT(chatID)");
				}
				return 0;
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if(rs != null) rs.close();
					if(pstmt != null) pstmt.close();
					if(conn != null) conn.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return -1; //데이터베이스 오류
		}
		
		//최근 대화 내용 반환
		public ArrayList<ChatDTO> getBox(String userID){
			ArrayList<ChatDTO> chatList = null;
			Connection conn = null;
			PreparedStatement pstmt = null; //SQL Injection같은 해킹공격을 방어해주고 안정적으로 SQL문을 실행하게 해줌
			ResultSet rs = null;
			String SQL = "SELECT * FROM CHAT WHERE chatID IN (SELECT MAX(chatID) FROM CHAT WHERE toID = ? OR fromID = ? GROUP BY fromID, toID)";
			try {
				conn = dataSource.getConnection();
				pstmt = conn.prepareStatement(SQL);
				pstmt.setString(1, userID);
				pstmt.setString(2, userID);
				rs = pstmt.executeQuery();
				chatList = new ArrayList<ChatDTO>();
				while (rs.next()) {
					ChatDTO chat = new ChatDTO();
					chat.setChatID(rs.getInt("chatID"));
					//SQL injection, cross site scripting 공격 등에 대해 방어하기 위해 특수문자 치환
					chat.setFromID(rs.getString("fromID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>")); 
					chat.setToID(rs.getString("toID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
					chat.setChatContent(rs.getString("chatContent").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
					int chatTime = Integer.parseInt(rs.getString("chatTime").substring(11, 13));
					String timeType = "오전";
					if (chatTime == 12) {
						timeType = "오후";
					}
					else if(chatTime > 12) {
						timeType = "오후";
						chatTime -= 12;
					}
					chat.setChatTime(rs.getString("chatTime").substring(0, 11) + " " + timeType + " " + chatTime + ":" + rs.getString("chatTime").substring(14, 16) + "");
					chatList.add(chat);
				}
				// 대화하는 사람 별로 가장 최신 메시지를 표시하기 위한 루프문
				for(int i = 0; i < chatList.size(); i++) {
					ChatDTO x = chatList.get(i);
					for(int j = 0; j < chatList.size(); j++) {
						ChatDTO y = chatList.get(j);
						if(x.getFromID().equals(y.getToID()) && x.getToID().equals(y.getFromID())) {
							if(x.getChatID() < y.getChatID()) {
								chatList.remove(x);
								i--;
								break;
							} else {
								chatList.remove(y);
								j--;
								break;
							}
						}
					}
				}
				//
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if(rs != null) rs.close();
					if(pstmt != null) pstmt.close();
					if(conn != null) conn.close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			return chatList; //리스트 반환
		}
}
