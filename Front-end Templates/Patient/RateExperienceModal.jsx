import React, { useState } from 'react';
import { Modal, Button, Rate, Input, Avatar } from 'antd';
import './patient.css';

const { TextArea } = Input;

const RateExperienceModal = ({ visible, onCancel, onSubmit }) => {
  const [rating, setRating] = useState(0);
  const [feedback, setFeedback] = useState('');

  return (
    <Modal
      title={<div className="rate-modal-title">Rate Your Experience</div>}
      open={visible}
      onCancel={onCancel}
      footer={null}
      className="rate-experience-modal"
      centered
      width={400}
      closeIcon={null}
    >
      <div className="rate-modal-profile">
        <Avatar 
          src="https://randomuser.me/api/portraits/women/44.jpg" 
          size={50} 
          className="rate-modal-avatar" 
        />
        <div className="rate-modal-info">
          <div className="rate-modal-name">Nurse Sarah Johnson</div>
          <div className="rate-modal-role">Registered Nurse</div>
        </div>
      </div>

      <div className="rate-modal-section">
        <div className="rate-modal-label">OVERALL RATING</div>
        <Rate 
          value={rating} 
          onChange={setRating} 
          className="rate-modal-stars"
        />
      </div>

      <div className="rate-modal-section">
        <div className="rate-modal-label-normal">Tell us more about your visit (Optional)</div>
        <TextArea
          rows={4}
          placeholder="Share your feedback here..."
          value={feedback}
          onChange={(e) => setFeedback(e.target.value)}
          className="rate-modal-textarea"
        />
      </div>

      <div className="rate-modal-actions">
        <Button type="text" onClick={onCancel} className="rate-modal-cancel-btn">
          Cancel
        </Button>
        <Button 
          type="primary" 
          onClick={() => onSubmit({ rating, feedback })}
          className="rate-modal-submit-btn"
        >
          Submit Rating
        </Button>
      </div>
    </Modal>
  );
};

export default RateExperienceModal;
