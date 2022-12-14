USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_WDEA_AD_BitacoraLayoutWDEA_ADINCO_SAP'
)
    DROP PROCEDURE SP_WDEA_AD_BitacoraLayoutWDEA_ADINCO_SAP;
GO
/****** Object:  StoredProcedure [dbo].[SP_WDEA_AD_BitacoraLayoutWDEA_ADINCO_SAP]    Script Date: 09/12/2022 11:51:45 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 26/10/2022
-- Description:	Consulta del registro de datos
-- =============================================
CREATE PROCEDURE [dbo].[SP_WDEA_AD_BitacoraLayoutWDEA_ADINCO_SAP]
	-- Add the parameters for the stored procedure here
	@FechaInicio DATETIME,
	@FechaFin DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
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
      ,[CreadoEL]
      ,[ModificadoEL]
      ,[RowN]
      ,[IdBitacoraLectura]
      ,[GL_Account]
      ,[Purchasing_Group]
      ,[Material_Group]
      ,[Created_On]
      ,[Mecanismo_de_Contratacion]
	FROM WDEA_Layout_T (NOLOCK)
	WHERE dbo.convertirFechaString(Created_On) BETWEEN CAST(@FechaInicio AS date) AND CAST(@FechaFin AS date) 
	ORDER BY RowN,CreadoEL DESC

END
