create PROC p_SIPAC_ImportRML_CONT_28_M_INS
@IdBitacora int,
@RF_00 varchar(200),
@RI_00 varchar(200),
@RF01_01 varchar(200),
@RMLCT28_00 tinyint,
@RMLCT28_01 smallint,
@RMLCT28_02 tinyint,
@RMLCT28_03 smallint,
@RMLCT28_04 decimal(18,2),
@CreadoPor int
AS
BEGIN

INSERT INTO [dbo].[SIPAC_ImportRML_CONT_28_M]
           ([IdBitacora]
           ,[RF_00]
           ,[RI_00]
           ,[RF01_01]
           ,[RMLCT28_00]
           ,[RMLCT28_01]
           ,[RMLCT28_02]
           ,[RMLCT28_03]
           ,[RMLCT28_04]
           ,[CreadoPor]
           ,[CreadoEl])
     VALUES
           (@IdBitacora,
			@RF_00,
			@RI_00,
			@RF01_01,
			@RMLCT28_00,
			@RMLCT28_01,
			@RMLCT28_02,
			@RMLCT28_03,
			@RMLCT28_04,
			@CreadoPor,
			GETDATE())

END


