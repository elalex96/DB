USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_InsLayoutAX]    Script Date: 25/08/2021 12:05:25 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <25/08/2021>  
-- Description: <guardado de datos de servicio de lectura de correos para WDEA>  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_InsLayoutWDEA] 
@LayoutWDEA dbo.WDEA_Layout_T READONLY,
@Remitente NVARCHAR(100),
@FileName NVARCHAR(500),
@Asunto NVARCHAR(500),
@Destinatario NVARCHAR(100)
AS
BEGIN

	DECLARE @MENSAJELECUTRA NVARCHAR(MAX) = '';
	DECLARE @CANT_GUARDADOS INT = 0;

    --SE INSERTAN LOS NUEVOS  
    INSERT INTO dbo.WDEA_Layout_T
    (
		   [Item]
		  ,[Purch_Organization]
		  ,[Cost_Center]
		  ,[WBS_Element]
		  ,[Short_Text]
		  ,[Outline_Agreegement]
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
		  ,[CreadoEl]
    )
    SELECT [Item]
      ,[Purch_Organization]
      ,[Cost_Center]
      ,[WBS_Element]
      ,[Short_Text]
      ,[Outline_Agreegement]
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
      ,GETDATE()
    FROM @LayoutWDEA;

	SET @CANT_GUARDADOS = (SELECT COUNT(1) FROM @LayoutWDEA);

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

	SELECT @CANT_GUARDADOS;

END
