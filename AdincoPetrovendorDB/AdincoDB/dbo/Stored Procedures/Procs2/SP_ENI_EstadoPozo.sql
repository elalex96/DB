USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_ENI_EstadoPozo]    Script Date: 04/06/2021 01:32:05 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <02-06-2021>
-- Description:	<cosnulta de estados de pozozs>
-- =============================================
ALTER PROCEDURE [dbo].[SP_ENI_EstadoPozo]
	-- Add the parameters for the stored procedure here
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT
		EP.idEstatus,
		EP.TipoEstatus
	FROM dbo.CO_Instalacion I
             JOIN dbo.CO_ActividadCIEP A ON I.IdActividad = A.IdActividad
             JOIN dbo.CO_EstadoPozos EP ON EP.idEstatus = I.IdEstatus
             JOIN dbo.CO_AreaContractual AC ON I.IdAreaContractual = AC.IdAreaContractual
             JOIN dbo.CO_Contrato C ON AC.IdAreaContractual = C.IdAreaContractual
        WHERE C.IdContrato = @IdContrato
              AND A.IdActividad = 5;

END