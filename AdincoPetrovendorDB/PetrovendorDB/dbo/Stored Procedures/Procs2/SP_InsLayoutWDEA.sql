USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_InsLayoutWDEA]    Script Date: 23/08/2022 10:16:09 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <25/08/2021>  
-- Description: <guardado de datos de servicio de lectura de correos para WDEA>  
-- =============================================  
ALTER PROCEDURE [dbo].[SP_InsLayoutWDEA] 
@LayoutWDEA dbo.WDEA_Layout_T_V4 READONLY,
@Remitente NVARCHAR(100),
@FileName NVARCHAR(500),
@Asunto NVARCHAR(500),
@Destinatario NVARCHAR(100)
AS
BEGIN

	DECLARE @MENSAJELECUTRA NVARCHAR(MAX) = '';
	DECLARE @CANT_GUARDADOS INT = 0;
	DECLARE @IDBITACORA INT = 0;

	SET @CANT_GUARDADOS = (SELECT COUNT(1) FROM @LayoutWDEA WHERE Item <> '');

	SET @MENSAJELECUTRA = ('SE GUARDARON ' + CAST(@CANT_GUARDADOS AS nvarchar) + ' REGISTROS EXITOSAMENTE, ENCONTRADOS EN EL ARCHIVO "' + @FileName + '" ENVIADO POR ' + @Remitente + ' A ' + @Destinatario + ' EN EL CORREO CON ASUNTO "' + @Asunto + '".');

	INSERT INTO AX_BitacoraLecturaCorreos
	(
		Asunto,
		CantidadArchivos,
		FechaLectura,
		EnviadoPor,
		ServicioOperadora,
		FechaRegBitacora,
		RecibidoPor,
		IsError
	)
	VALUES
	(
		@MENSAJELECUTRA,
		1,
		GETDATE(),
		@Remitente,
		'WDEA-LAYOUT',
		GETDATE(),
		@Destinatario,
		0
	);

	SET @IDBITACORA = @@IDENTITY;

    --SE INSERTAN LOS NUEVOS  
    INSERT INTO dbo.WDEA_Layout_T
    (
		   [Item]
		  ,[Purch_Organization]
		  ,[Cost_Center]
		  ,[WBS_Element]
		  ,[Outline_Agreegement]
		  ,[Short_Text]
		  ,[Validity_Per_Start]
		  ,[Validity_Period_End]
		  ,[Deletion_Indicador]
		  ,[Plant]
		  ,[Order_Quantity]
		  ,[Order_Unit]
		  ,[Net_Price]
		  ,[Currency]
		  ,[Vendor_Supplying_Plant]
		  ,[Purchasing_Document]
		  ,[Release_State]
		  ,[Name_of_Vendor]
		  ,[Order_Price_Unit]
		  ,[Net_Order_Value]
		  ,[Requisitioner]
		  ,[Terminos_Pago]
		  ,[Justificacion]
		  ,[GL_Account]
		  ,[Purchasing_Group]
		  ,[Material_Group]
		  ,[Created_On]
		  ,[Mecanismo_de_Contratacion]
		  ,[CreadoEl]
		  ,RowN
		  ,IdBitacoraLectura
    )
    SELECT [Item]
      ,[Purch_Organization]
      ,[Cost_Center]
      ,[WBS_Element]
      ,[Outline_Agreegement]
      ,[Short_Text]
      ,[Validity_Per_Start]
      ,[Validity_Period_End]
      ,[Deletion_Indicador]
      ,[Plant]
      ,[Order_Quantity]
      ,[Order_Unit]
      ,[Net_Price]
      ,[Currency]
      ,[Vendor_Supplying_Plant]
      ,[Purchasing_Document]
      ,[Release_State]
      ,[Name_of_Vendor]
      ,[Order_Price_Unit]
	  ,[Net_Order_Value]
      ,[Requisitioner]
      ,[Terminos_Pago]
      ,[Justificacion]
	  ,[GL_Account]
	  ,[Purchasing_Group]
	  ,[Material_Group]
	  ,CASE
			WHEN [Created_On] = '0' OR [Created_On] = '' OR [Created_On] = '00/00/0000' THEN CONVERT(varchar,GETDATE(),103)
			ELSE [Created_On]
		END
	  ,[Mecanismo_de_Contratacion]
      ,GETDATE()
	  ,CAST(RowN AS INT)
	  ,@IDBITACORA
    FROM @LayoutWDEA
	WHERE Item <> '';

	SELECT @IDBITACORA;

	exec SP_Ins_WDEA_Bitacora_AdincoSAP @IDBITACORA
END