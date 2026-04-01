<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>TP2 — App Java -> MySQL</title>
  <style>
    body { font-family: 'Segoe UI', sans-serif; background: #0f172a; color: #f8fafc; padding: 40px; }
    .container { max-width: 800px; margin: auto; background: #1e293b; padding: 30px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
    h1 { color: #38bdf8; border-bottom: 2px solid #334155; padding-bottom: 10px; }
    .status { padding: 15px; border-radius: 8px; margin: 20px 0; font-weight: bold; }
    .success { background: rgba(34, 197, 94, 0.2); border: 1px solid #22c55e; color: #4ade80; }
    .error { background: rgba(239, 68, 68, 0.2); border: 1px solid #ef4444; color: #f87171; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { text-align: left; padding: 12px; border-bottom: 1px solid #334155; }
    th { background: #334155; color: #38bdf8; }
    .badge { display: inline-block; padding: 4px 10px; border-radius: 4px; font-size: 0.8rem; background: #38bdf8; color: #0f172a; margin-right: 10px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>🚀 TP2 - Application Web Java Distante</h1>
    <p>Cette application tourne sur <strong>srv-app</strong> et se connecte à <strong>srv-db</strong> (MySQL).</p>

    <%
      String dbUrl = "jdbc:mysql://10.0.2.2:3306/appdb?useSSL=false&allowPublicKeyRetrieval=true";
      String dbUser = "appuser";
      String dbPass = "AppPass123!";
      
      Connection conn = null;
      try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
    %>
        <div class="status success">✅ Connexion à la base de données RÉUSSIE !</div>
        
        <h3>Contenu de la table <code>messages</code> :</h3>
        <table>
          <tr>
            <th>ID</th>
            <th>Message</th>
            <th>Date</th>
          </tr>
          <%
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM messages");
            while (rs.next()) {
          %>
              <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("content") %></td>
                <td><%= rs.getTimestamp("created_at") %></td>
              </tr>
          <%
            }
          %>
        </table>
    <%
      } catch (Exception e) {
    %>
        <div class="status error">❌ Échec de la connexion à la base de données.</div>
        <p style="color: #f87171;"><strong>Erreur :</strong> <%= e.getMessage() %></p>
        <p><em>Vérifiez que srv-db tourne et que le port 3306 est bien transféré.</em></p>
    <%
      } finally {
        if (conn != null) conn.close();
      }
    %>

    <div style="margin-top: 30px; font-size: 0.9rem; color: #94a3b8;">
      <span class="badge">Serveur App</span> Tomcat 9 (srv-app)<br>
      <span class="badge">Serveur DB</span> MySQL 8 (srv-db)<br>
      <span class="badge">JDBC URL</span> <%= dbUrl %>
    </div>
  </div>
</body>
</html>
