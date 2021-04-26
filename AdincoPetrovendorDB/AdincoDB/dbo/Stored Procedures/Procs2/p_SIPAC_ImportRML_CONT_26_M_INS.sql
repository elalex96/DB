CREATE PROC p_SIPAC_ImportRML_CONT_26_M_INS
@IdBitacora int,
@RF_00 varchar(200),
@RI_00 varchar(200),
@RF01_01 varchar(200),
@RMLCT26_00 tinyint,
@RMLCT26_01 smallint,
@RMLCT26_02 int,
@RMLCT26_03 int,
@RMLCT26_04 int,
@RMLCT26_05 int,
@RMLCT26_06 int,
@RMLCT26_07 int,
@RMLCT26_08 int,
@RMLCT26_09 int,
@RMLCT26_10 int,
@RMLCT26_11 int,
@RMLCT26_12 int,
@RMLCT26_13 int,
@RMLCT26_14 int,
@RMLCT26_15 int,
@RMLCT26_16 int,
@RMLCT26_17 decimal(10,4),
@RMLCT26_18 decimal(10,4),
@RMLCT26_19 decimal(10,4),
@RMLCT26_20 decimal(10,4),
@RMLCT26_21 decimal(10,2),
@RMLCT26_22 tinyint,
@RMLCT26_23 tinyint,
@RMLCT26_24 tinyint,
@RMLCT26_25 tinyint,
@RMLCT26_26 tinyint,
@RMLCT26_27 tinyint,
@RMLCT26_28 tinyint,
@RMLCT26_29 tinyint,
@RMLCT26_30 tinyint,
@RMLCT26_31 tinyint,
@RMLCT26_32 float,
@RMLCT26_33 float,
@RMLCT26_34 float,
@RMLCT26_35 float,
@RMLCT26_36 float,
@CreadoPor int

AS
BEGIN

INSERT INTO [dbo].[SIPAC_ImportRML_CONT_26_M]
           ([IdBitacora]
           ,[RF_00]
           ,[RI_00]
           ,[RF01_01]
           ,[RMLCT26_00]
           ,[RMLCT26_01]
           ,[RMLCT26_02]
           ,[RMLCT26_03]
           ,[RMLCT26_04]
           ,[RMLCT26_05]
           ,[RMLCT26_06]
           ,[RMLCT26_07]
           ,[RMLCT26_08]
           ,[RMLCT26_09]
           ,[RMLCT26_10]
           ,[RMLCT26_11]
           ,[RMLCT26_12]
           ,[RMLCT26_13]
           ,[RMLCT26_14]
           ,[RMLCT26_15]
           ,[RMLCT26_16]
           ,[RMLCT26_17]
           ,[RMLCT26_18]
           ,[RMLCT26_19]
           ,[RMLCT26_20]
           ,[RMLCT26_21]
           ,[RMLCT26_22]
           ,[RMLCT26_23]
           ,[RMLCT26_24]
           ,[RMLCT26_25]
           ,[RMLCT26_26]
           ,[RMLCT26_27]
           ,[RMLCT26_28]
           ,[RMLCT26_29]
           ,[RMLCT26_30]
           ,[RMLCT26_31]
           ,[RMLCT26_32]
           ,[RMLCT26_33]
           ,[RMLCT26_34]
           ,[RMLCT26_35]
           ,[RMLCT26_36]
           ,[CreadoPor]
           ,[CreadoEl])
     VALUES
           (@IdBitacora,
			@RF_00,
			@RI_00,
			@RF01_01,
			@RMLCT26_00,
			@RMLCT26_01,
			@RMLCT26_02,
			@RMLCT26_03,
			@RMLCT26_04,
			@RMLCT26_05,
			@RMLCT26_06,
			@RMLCT26_07,
			@RMLCT26_08,
			@RMLCT26_09,
			@RMLCT26_10,
			@RMLCT26_11,
			@RMLCT26_12,
			@RMLCT26_13,
			@RMLCT26_14,
			@RMLCT26_15,
			@RMLCT26_16,
			@RMLCT26_17,
			@RMLCT26_18,
			@RMLCT26_19,
			@RMLCT26_20,
			@RMLCT26_21,
			@RMLCT26_22,
			@RMLCT26_23,
			@RMLCT26_24,
			@RMLCT26_25,
			@RMLCT26_26,
			@RMLCT26_27,
			@RMLCT26_28,
			@RMLCT26_29,
			@RMLCT26_30,
			@RMLCT26_31,
			@RMLCT26_32,
			@RMLCT26_33,
			@RMLCT26_34,
			@RMLCT26_35,
			@RMLCT26_36,
			@CreadoPor,
			GETDATE())


end
GO


