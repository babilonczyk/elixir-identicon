# Elixir Identicon

The goal of this project is to create a simple application that will generate the Github-like logo images, based on the string input. They should be "replicable", meaning once the same input was passed, the same identicon will be generated.

```mermaid
  graph LR;
      Generation[Identicon Generation]
      String-->Generation;
      Generation-->Image;
```

If String1 = String2, we receive the same image

```mermaid
  graph LR;
      String1-->Image;
      String2-->Image;
```

Pipeline:

```mermaid
  graph TB;
      Step1[String]
      Step2[Compute hash of string]
      Step3[List of numbers based of the string]
      Step4[Pick color]
      Step5[Build grid of squares]
      Step6[Convert grid to image]
      Step7[Save Image]

      Step1-->Step2;
      Step2-->Step3;
      Step3-->Step4;
      Step4-->Step5;
      Step5-->Step6;
      Step6-->Step7;
```
