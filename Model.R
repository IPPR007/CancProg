
target.gene="NETcluster" 
mrmr_n= 20
n_rfe = c(3:9)

library(CBCgrps)
library(survival)
library(survminer)
library(jskm)
library(forestplot)
library(mRMRe)
library(pROC)
library(rms)
library(ggDCA)
library(caret)
library(yardstick)

y=rt[,'label']
rt$label = ifelse(rt$label == 'Low', 0, 1)
Data <- mRMR.data(data = data.frame(rt))
mrmr <- mRMR.classic("mRMRe.Filter", data = Data, target_indices = 1, feature_count = mrmr_n)
index = mrmr@filters[[as.character(mrmr@target_indices)]]
var_mRMR = names(rt[, c(index)])

rt <- rt[var_mRMR]
x = as.matrix(rt)
ctrl <- rfeControl(functions = rfFuncs,
                   method = "CV",
                   number=10,
                   repeats = 1,
                   verbose = FALSE)
metric = ifelse(is.factor(y), "Accuracy", "RMSE")
lmProfile <- rfe(x=x, y=y, 
                 sizes = rfe_n,
                 metric = metric,
                 maximize = ifelse(metric %in% c("RMSE", "MAE", "logLoss"), FALSE, TRUE),
                 rfeControl = ctrl)
var_RFE<-predictors(lmProfile)

fitControl <- trainControl(
    method = "cv",
    number = 10,
    classProbs = TRUE,
    summaryFunction = twoClassSummary,
    selectionFunction = "tolerance"
)

formula <- as.formula(paste0('label', " ~ ", paste0(var, collapse = '+')))

svm_Grid <- expand.grid(cost = 2 ^ ((1:7) - 4),weight = 1:5)
svm_Fit <- train(
    formula,
    data = rt,
    method = "svmLinearWeights",
    trControl = fitControl,
    metric = "ROC",
    tuneGrid = svm_Grid

predictions <- predict(svm_Fit, newdata = rt)
confusion <- confusionMatrix(predictions, rt$label)

data <- data.frame(Actual = rt$label, Prediction = predict(svm_Fit, newdata = rt))
cm <- conf_mat(data, truth = Actual, estimate = Prediction)

autoplot(cm, type = "heatmap") + scale_fill_gradient(low = "blue", high = rc[2])

pred_prob <- predict(svm_Fit, rt, type = "prob")[, 2]
roc_obj <- roc(rt$label, pred_prob)
auc_value <- auc(roc_obj)
brier_score <- mean((pred_prob - as.numeric(rt$label))^2)

wilcox_result <- wilcox.test(prob ~ label, data = rt_train)
pValue <- wilcox_result$p.value

r_glm <- glm(label ~ ., family = binomial(link = "logit"), data = rt)