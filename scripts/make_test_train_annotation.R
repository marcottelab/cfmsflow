neg_test <- read.table("allplants.labels.filt.negtest.20k_a", sep="\t")
neg_test$var <- "NegTest"

pos_test <- read.table("allComplexesCore_photo_euktovirNOG_expansion_merged09_size30_rmLrg_outsidesupport.test_ppis.txt.ordered", sep="\t")
pos_test$var <- "PosTest"



neg_train <- read.table("allplants.labels.filt.negtrain.20k_a", sep="\t")
neg_train$var <- "NegTrain"


pos_train <- read.table("allComplexesCore_photo_euktovirNOG_expansion_merged09_size30_rmLrg_outsidesupport.train_ppis.txt.ordered", sep="\t")
pos_train$var <- "PosTrain"


annotation <- rbind(pos_train, pos_test, neg_train, neg_test)
names(annotation) <- c("ID1", "ID2", "set")

write.table(annotation, "allComplexesCore_photo_euktovirNOG_expansion_merged09_size30_rmLrg_outsidesupport_TrainTestPosNegSet.csv", row.names=FALSE, quote=FALSE, sep=",")

