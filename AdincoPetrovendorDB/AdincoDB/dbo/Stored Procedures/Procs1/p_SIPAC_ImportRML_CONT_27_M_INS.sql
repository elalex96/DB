create proc p_SIPAC_ImportRML_CONT_27_M_INS
@IdBitacora int,
@RF_00 varchar(200),
@RI_00 varchar(200),
@RF01_01 varchar(200),
@RMLCT27_00 date,
@RMLCT27_01 int,
@RMLCT27_02 tinyint,
@RMLCT27_03 int,
@RMLCT27_04 decimal(10,4),
@RMLCT27_05 decimal(10,4),
@RMLCT27_06 decimal(10,4),
@RMLCT27_07 varchar(50),
@RMLCT27_08 varchar(50),
@RMLCT27_09 varchar(50),
@RMLCT27_10 varchar(50),
@RMLCT27_11 tinyint,
@RMLCT27_12 tinyint,
@RMLCT27_13 tinyint,
@CreadoPor int
AS
BEGIN

INSERT INTO [dbo].[SIPAC_ImportRML_CONT_27_M]
           ([IdBitacora]
           ,[RF_00]
           ,[RI_00]
           ,[RF01_01]
           ,[RMLCT27_00]
           ,[RMLCT27_01]
           ,[RMLCT27_02]
           ,[RMLCT27_03]
           ,[RMLCT27_04]
           ,[RMLCT27_05]
           ,[RMLCT27_06]
           ,[RMLCT27_07]
           ,[RMLCT27_08]
           ,[RMLCT27_09]
           ,[RMLCT27_10]
           ,[RMLCT27_11]
           ,[RMLCT27_12]
           ,[RMLCT27_13]
           ,[CreadoPor]
           ,[CreadoEl])
     VALUES
           (@IdBitacora,
			@RF_00,
			@RI_00,
			@RF01_01,
			@RMLCT27_00,
			@RMLCT27_01,
			@RMLCT27_02,
			@RMLCT27_03,
			@RMLCT27_04,
			@RMLCT27_05,
			@RMLCT27_06,
			@RMLCT27_07,
			@RMLCT27_08,
			@RMLCT27_09,
			@RMLCT27_10,
			@RMLCT27_11,
			@RMLCT27_12,
			@RMLCT27_13,
			@CreadoPor,
			getdate())


END


