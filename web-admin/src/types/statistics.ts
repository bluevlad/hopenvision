export interface ExamStatistics {
  examCd: string;
  examNm: string;
  totalApplicants: number;
  passedCount: number;
  passRate: number;
  avgScore: number | null;
  maxScore: number | null;
  minScore: number | null;
  scoreDistributions: ScoreDistribution[];
  subjectStatistics: SubjectStatistics[];
}

export interface SubjectStatistics {
  subjectCd: string;
  subjectNm: string;
  applicantCount: number;
  avgScore: number | null;
  maxScore: number | null;
  minScore: number | null;
}

export interface ScoreDistribution {
  range: string;
  count: number;
  percentage: number;
}
