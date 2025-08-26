class AssessmentModule < LessonModule
  # Assessment-specific validations
  validates :questions, presence: true
  
  # Assessment-specific settings
  def self.default_settings
    {
      time_limit: nil, # in minutes
      passing_score: 70,
      allow_retakes: true,
      show_results: true,
      randomize_questions: false,
      show_correct_answers: true,
      require_completion: true
    }
  end
  
  # Instance methods
  def questions
    settings['questions'] || []
  end
  
  def questions=(value)
    settings['questions'] = value
  end
  
  def time_limit
    settings['time_limit']
  end
  
  def time_limit=(value)
    settings['time_limit'] = value
  end
  
  def passing_score
    settings['passing_score'] || 70
  end
  
  def passing_score=(value)
    settings['passing_score'] = value
  end
  
  def total_points
    questions.sum { |q| q['points'] || 1 }
  end
  
  def question_count
    questions.length
  end
  
  def estimated_time
    return time_limit if time_limit.present?
    # Estimate 2 minutes per question if no time limit set
    question_count * 2
  end
  
  def validate_questions
    return false if questions.blank?
    
    questions.all? do |question|
      question['text'].present? && 
      question['type'].present? && 
      %w[multiple_choice single_choice true_false].include?(question['type']) &&
      question['options'].present? &&
      question['options'].is_a?(Array) &&
      question['options'].length >= 2
    end
  end
  
  # Class methods
  def self.display_name
    'Assessment Module'
  end
  
  def self.description
    'Interactive quizzes and assessments with scoring'
  end
end
