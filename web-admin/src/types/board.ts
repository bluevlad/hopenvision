export interface BoardListItem {
  boardId: number;
  subject: string | null;
  regDt: string | null;
  hits: number | null;
  author: string | null;
  legacySource: string | null;
  noticeTop: boolean;
  hidden: boolean;
}

export interface BoardReply {
  boardId: number;
  subject: string | null;
  content: string | null;
  regDt: string | null;
  author: string | null;
}

export interface BoardDetail {
  boardId: number;
  subject: string | null;
  content: string | null;
  answer: string | null;
  regDt: string | null;
  updDt: string | null;
  hits: number | null;
  author: string | null;
  legacySource: string | null;
  noticeTop: boolean;
  hidden: boolean;
  replies: BoardReply[];
}
