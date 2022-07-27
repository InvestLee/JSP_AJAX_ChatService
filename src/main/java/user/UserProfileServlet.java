package user;

import java.io.File;
import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

@WebServlet("/UserProfileServlet")
public class UserProfileServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/html;charset=UTF-8");
		MultipartRequest multi = null;
		int fileMaxSize = 10 * 1024 * 1024;
		String savePath = request.getRealPath("/upload").replaceAll("\\\\", "/");
		try {
			//DefaultFileRenamePolicy 파일이름이 겹치는 경우 자동으로 처리
			multi = new MultipartRequest(request, savePath, fileMaxSize, "UTF-8", new DefaultFileRenamePolicy());
		} catch (Exception e) {
			request.getSession().setAttribute("messageType", "오류 메시지");
			request.getSession().setAttribute("messageContent", "파일 크기는 10MB를 넘을 수 없습니다.");
			response.sendRedirect("profileUpdate.jsp");
			return;
		}
		String userID = multi.getParameter("userID");
		HttpSession session = request.getSession(); //세션 값 검증(본인만 회원정보 수정할 수 있어야 함)
		if(!userID.equals((String) session.getAttribute("userID"))){
			session.setAttribute("messageType", "오류 메시지");
			session.setAttribute("messageContent", "접근할 수 없습니다.");
			response.sendRedirect("index.jsp");
			return;
		}
		String fileName = "";
		File file = multi.getFile("userProfile");
		if(file != null) {
			String ext = file.getName().substring(file.getName().lastIndexOf(".")+1); //파일 확장자 확인
			if(ext.equals("jpg") || ext.equals("png") || ext.equals("gif") ) {
				//이전 사진파일 삭제 후 업로드
				String prev = new UserDAO().getUser(userID).getUserProfile();
				File prevFile = new File(savePath + "/" + prev);
				if(prevFile.exists()) {
					prevFile.delete();
				}
				fileName = file.getName();
			} else {
				if(file.exists()) {
					file.delete();
				}
				request.getSession().setAttribute("messageType", "오류 메시지");
				request.getSession().setAttribute("messageContent", "jpg, png, gif 파일만 업로드 가능합니다.");
				response.sendRedirect("profileUpdate.jsp");
				return;
			}
		} else {
			request.getSession().setAttribute("messageType", "오류 메시지");
			request.getSession().setAttribute("messageContent", "수정할 사진 파일이 업로드 되어있지 않습니다.");
			response.sendRedirect("profileUpdate.jsp");
			return;
		}
		new UserDAO().profile(userID, fileName); //데이터 베이스와 연동하여 해당 사용자 프로필 변경
		request.getSession().setAttribute("messageType", "성공 메시지");
		request.getSession().setAttribute("messageContent", "프로필 사진이 수정되었습니다.");
		response.sendRedirect("index.jsp");
		return;
	}
}
