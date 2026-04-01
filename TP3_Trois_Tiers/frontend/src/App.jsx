import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [messages, setMessages] = useState([])
  const [newMessage, setNewMessage] = useState('')

  useEffect(() => {
    fetchMessages()
  }, [])

  const fetchMessages = async () => {
    try {
      const response = await fetch('/api/messages')
      const data = await response.json()
      setMessages(data)
    } catch (error) {
      console.error('Error fetching messages:', error)
    }
  }

  const addMessage = async (e) => {
    e.preventDefault()
    if (!newMessage.trim()) return

    try {
      await fetch('/api/messages', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ content: newMessage }),
      })
      setNewMessage('')
      fetchMessages()
    } catch (error) {
      console.error('Error adding message:', error)
    }
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>TP3 DevOps - Vagrant 3-Tiers</h1>
        <p>Frontend ⇄ Backend ⇄ Base de Données</p>
      </header>
      <main>
        <section className="messages-section">
          <h2>Messages de la Base de Données</h2>
          <ul className="messages-list">
            {messages.map((msg, index) => (
              <li key={index}>{msg.content} <span className="date">({new Date(msg.createdAt).toLocaleString()})</span></li>
            ))}
            {messages.length === 0 && <li>Aucun message trouvé.</li>}
          </ul>
        </section>
        
        <section className="add-message-section">
          <h3>Ajouter un Message</h3>
          <form onSubmit={addMessage}>
            <input 
              type="text" 
              value={newMessage} 
              onChange={(e) => setNewMessage(e.target.value)} 
              placeholder="Écrivez votre message..."
            />
            <button type="submit">Envoyer</button>
          </form>
        </section>
      </main>
    </div>
  )
}

export default App
