USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_ContratosActivos'
)
    DROP PROCEDURE MM_ContratosActivos;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <2107/2023>
-- Description:	<Consulta de los contratos activos>
-- =============================================
CREATE PROCEDURE [dbo].[MM_ContratosActivos]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	DISTINCT
				C.NumeroContrato, 
				A.NombreAreaContractual ,
				C.NumeroContrato + ' - ' + A.NombreAreaContractual AS Contrato ,
				C.IdContrato, 
				C.IdAreaContractual
		 FROM	Adinco..CO_Contrato AS C
		 INNER JOIN Adinco..CO_AreaContractual AS A
		 ON A.IdAreaContractual = C.IdAreaContractual
		 WHERE C.Activo = 1
		 ORDER BY NumeroContrato DESC
END
