package user;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@WebServlet("/UserFindServlet")
public class UserFindServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/html;charset=UTF-8");
		String userID = request.getParameter("userID");
		if(userID == null || userID.equals("")) {
			response.getWriter().write("-1"); //빈칸인 경우 오류메시지
		} else if (new UserDAO().registerCheck(userID) == 0) {
			try {
				response.getWriter().write(find(userID)); //성공적으로 회원가입이 되어있는 경우
			} catch (Exception e) {
				e.printStackTrace();
				response.getWriter().write("-1");
			}
		} else {
			response.getWriter().write("-1"); //회원가입이 안된 사용자인 경우 오류메시지
		}
	}
	
	public String find(String userID) throws Exception {
		StringBuffer result = new StringBuffer("");
		result.append("{\"userProfile\":\"" + new UserDAO().getProfile(userID) + "\"}");
		return result.toString();
	}
}
