import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';

@Component({
  selector: 'app-summarizer',
  templateUrl: './summarizer.component.html',
  styleUrls: ['./summarizer.component.css']
})
export class SummarizerComponent {
  constructor(private http: HttpClient) { }

  inputText: string = '';
  summary: string = '';
  errorMessage: string = '';
  summaryLength: number = 3;

  onSubmit() {
    this.getSummary(this.inputText).subscribe(
      (data: any) => {
        this.summary = data.summary;
      },
      (error) => {
        this.showError('An error occurred while summarizing the text. Please try again.');
      }
    );
  }
  
  getSummary(text: string) {
    return this.http.post(environment.apiUrl, { text: text, length: this.summaryLength});
  }

  showError(message: string, duration: number = 5000) {
    this.errorMessage = message;
    setTimeout(() => {
      this.errorMessage = '';
    }, duration);
  }
}
