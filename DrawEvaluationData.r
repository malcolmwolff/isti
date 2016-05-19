
##########################################################
# DrawEvaluationData.r
# 2016.05.18
# Sample fake evaluation data for practice.
##########################################################
library(dplyr)
set.seed(12345)


# Simulation parameters
num.eval  <- 5     # Number of evaluations per teacher candidate.
num.teach <- 200   # Number of teacher candidates.
var.item  <- 0.10  # Rubric item fx variance component.
var.pers  <- 0.40  # Person fx variance component.
var.rate  <- 0.10  # Rater fx variance component.
var.resid <- 1 - var.item - var.pers - var.rate
pr1       <- 0.03  # Proportion with eval<=1
pr2       <- 0.10  # Proportion with eval<=2
pr3       <- 0.40  # Proportion with eval<=3
pr4       <- 0.80  # Proportion with eval<=4


# Define the teaching rubric.
questions <- data.frame(
  question_num = c(1:23), 
  question_name = c("Instructional Plans", 
                    "Student Work", 
                    "Assessment", 
                    "Expectations", 
                    "Managing Student Behavior", 
                    "Environment", 
                    "Respectful Culture", 
                    "Standards and Objectives", 
                    "Motivating Students", 
                    "Presenting Instructional Content", 
                    "Lesson Structure and Pacing", 
                    "Activities and Materials", 
                    "Questioning", 
                    "Academic Feedback", 
                    "Grouping", 
                    "Teacher Content Knowledge", 
                    "Teacher Knowledge of Students", 
                    "Thinking", 
                    "Problem-Solving", 
                    "Professional Growth and Learning", 
                    "Use of Data", 
                    "School and Community Involvement", 
                    "Leadership"))
num.item <- nrow(questions)


# Draw teacher candidate true score data.
# I draw teacher evaluation true scores using a multivariate normal 
# disribution.
# The psychometrics are roughly based on Ho & Kane (2013), although
# I ignore rater effects and substitute item effects.
item.fx <- data.frame(item.id=1:num.item, 
                      item.fx=rnorm(num.item, mean=0, sd=sqrt(var.item)))
pers.fx <- data.frame(pers.id=1:num.teach, 
                      pers.fx=rnorm(num.teach, mean=0, sd=sqrt(var.pers)))
teach.truescore.data <- expand.grid(1:num.teach, 1:num.item)
names(teach.truescore.data) <- c("pers.id", "item.id")
teach.truescore.data <- merge(teach.truescore.data, item.fx, by="item.id")
teach.truescore.data <- merge(teach.truescore.data, pers.fx, by="pers.id")
rate.fx <- data.frame(pers.id=rep(1:num.teach, 2),
                      rate.id=1:(2*num.teach),
                      rate.fx=rnorm(2*num.teach, mean=0, sd=sqrt(var.rate)))
teach.truescore.data <- merge(teach.truescore.data, rate.fx, by="pers.id")


# Draw teacher candidate score data.
# I draw teacher evaluation data from the true score data and 
# then discretize to roughly match observed score distributions.
teach.data <- expand.grid(1:num.teach, 1:num.item, 1:num.eval)
names(teach.data) <- c("pers.id", "item.id", "eval.id")
teach.data <- merge(teach.data, teach.truescore.data, 
                    by=c("pers.id", "item.id"))
teach.data$resid <- rnorm(nrow(teach.data), mean=0, sd=sqrt(var.resid))
teach.data$score <- teach.data$pers.fx + teach.data$item.fx + 
  + teach.data$rate.fx + teach.data$resid
teach.data$eval  <- 1 * (teach.data$score < qnorm(pr1)) +
  2 * (teach.data$score >= qnorm(pr1) & teach.data$score < qnorm(pr2)) +
  3 * (teach.data$score >= qnorm(pr2) & teach.data$score < qnorm(pr3)) +
  4 * (teach.data$score >= qnorm(pr3) & teach.data$score < qnorm(pr4)) +
  5 * (teach.data$score >= qnorm(pr4))
teach.data <- select(arrange(teach.data, pers.id, rate.id, eval.id, item.id),
                     pers.id, rate.id, eval.id, item.id, eval)
teach.data <- reshape(teach.data, direction="wide",
                      v.names="eval",
                      timevar="item.id",
                      idvar=c("pers.id", "rate.id", "eval.id"))
write.table(teach.data, 
            file="evaldata.txt", 
            sep="\t", 
            row.names=FALSE,
            col.names=TRUE)
