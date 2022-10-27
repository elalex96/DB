USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_WDEA_AD_BitacoraLayoutWDEA_ADINCO_SAP]    Script Date: 27/10/2022 10:50:23 a. m. ******/
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
	SELECT * 
	FROM WDEA_Layout_T 
	WHERE len(rtrim(ltrim(Created_On))) > 6 AND cast(substring(Created_On,7,4)+'-'+ substring(Created_On,4,2)+'-'+substring(Created_On,0,3) as date) BETWEEN CAST(@FechaInicio AS date) AND CAST(@FechaFin AS date) 
	ORDER BY RowN,CreadoEL DESC

END

