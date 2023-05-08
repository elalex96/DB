create PROC p_SIPAC_ImportRML_CONT_25_M_INS
@IdBitacora int,
@RF_00 varchar(200),
@RI_00 varchar(200),
@RF01_01 varchar(200),
@RMLCT25_00 tinyint,
@RMLCT25_01 smallint,
@RMLCT25_02 int,
@RMLCT25_03 decimal(5,2),
@RMLCT25_04 decimal(5,2),
@RMLCT25_05 int,
@RMLCT25_06 int,
@RMLCT25_07 int,
@RMLCT25_08 int,
@RMLCT25_09 int,
@RMLCT25_10 int,
@RMLCT25_11 int,
@RMLCT25_12 int,
@RMLCT25_13 int,
@RMLCT25_14 int,
@RMLCT25_15 int,
@RMLCT25_16 int,
@RMLCT25_17 int,
@RMLCT25_18 int,
@RMLCT25_19 int,
@RMLCT25_20 int,
@RMLCT25_21 int,
@RMLCT25_22 decimal(10,4),
@RMLCT25_23 decimal(10,4),
@RMLCT25_24 decimal(10,4),
@RMLCT25_25 decimal(10,4),
@RMLCT25_26 decimal(10,4),
@RMLCT25_27 decimal(10,4),
@RMLCT25_28 tinyint,
@RMLCT25_29 tinyint,
@RMLCT25_30 tinyint,
@RMLCT25_31 tinyint,
@RMLCT25_32 tinyint,
@RMLCT25_33 tinyint,
@RMLCT25_34 tinyint,
@RMLCT25_35 tinyint,
@RMLCT25_36 tinyint,
@RMLCT25_37 tinyint,
@RMLCT25_38 tinyint,
@RMLCT25_39 tinyint,
@RMLCT25_40 decimal(10,4),
@RMLCT25_41 decimal(10,4),
@RMLCT25_42 decimal(10,4),
@RMLCT25_43 decimal(10,4),
@RMLCT25_44 decimal(10,4),
@RMLCT25_45 decimal(10,4),
@CreadoPor int
AS
BEGIN


INSERT INTO [dbo].[SIPAC_ImportRML_CONT_25_M]
           ([IdBitacora]
           ,[RF_00]
           ,[RI_00]
           ,[RF01_01]
           ,[RMLCT25_00]
           ,[RMLCT25_01]
           ,[RMLCT25_02]
           ,[RMLCT25_03]
           ,[RMLCT25_04]
           ,[RMLCT25_05]
           ,[RMLCT25_06]
           ,[RMLCT25_07]
           ,[RMLCT25_08]
           ,[RMLCT25_09]
           ,[RMLCT25_10]
           ,[RMLCT25_11]
           ,[RMLCT25_12]
           ,[RMLCT25_13]
           ,[RMLCT25_14]
           ,[RMLCT25_15]
           ,[RMLCT25_16]
           ,[RMLCT25_17]
           ,[RMLCT25_18]
           ,[RMLCT25_19]
           ,[RMLCT25_20]
           ,[RMLCT25_21]
           ,[RMLCT25_22]
           ,[RMLCT25_23]
           ,[RMLCT25_24]
           ,[RMLCT25_25]
           ,[RMLCT25_26]
           ,[RMLCT25_27]
           ,[RMLCT25_28]
           ,[RMLCT25_29]
           ,[RMLCT25_30]
           ,[RMLCT25_31]
           ,[RMLCT25_32]
           ,[RMLCT25_33]
           ,[RMLCT25_34]
           ,[RMLCT25_35]
           ,[RMLCT25_36]
           ,[RMLCT25_37]
           ,[RMLCT25_38]
           ,[RMLCT25_39]
           ,[RMLCT25_40]
           ,[RMLCT25_41]
           ,[RMLCT25_42]
           ,[RMLCT25_43]
           ,[RMLCT25_44]
           ,[RMLCT25_45]
           ,[CreadoPor]
           ,[CreadoEl])
     VALUES
           (@IdBitacora,
@RF_00,
@RI_00,
@RF01_01,
@RMLCT25_00,
@RMLCT25_01,
@RMLCT25_02,
@RMLCT25_03,
@RMLCT25_04,
@RMLCT25_05,
@RMLCT25_06,
@RMLCT25_07,
@RMLCT25_08,
@RMLCT25_09,
@RMLCT25_10,
@RMLCT25_11,
@RMLCT25_12,
@RMLCT25_13,
@RMLCT25_14,
@RMLCT25_15,
@RMLCT25_16,
@RMLCT25_17,
@RMLCT25_18,
@RMLCT25_19,
@RMLCT25_20,
@RMLCT25_21,
@RMLCT25_22,
@RMLCT25_23,
@RMLCT25_24,
@RMLCT25_25,
@RMLCT25_26,
@RMLCT25_27,
@RMLCT25_28,
@RMLCT25_29,
@RMLCT25_30,
@RMLCT25_31,
@RMLCT25_32,
@RMLCT25_33,
@RMLCT25_34,
@RMLCT25_35,
@RMLCT25_36,
@RMLCT25_37,
@RMLCT25_38,
@RMLCT25_39,
@RMLCT25_40,
@RMLCT25_41,
@RMLCT25_42,
@RMLCT25_43,
@RMLCT25_44,
@RMLCT25_45,
@CreadoPor,
GETDATE())

END