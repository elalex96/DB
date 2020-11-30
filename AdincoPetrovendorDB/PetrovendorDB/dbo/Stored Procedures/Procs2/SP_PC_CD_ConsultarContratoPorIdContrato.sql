-- =============================================
-- Author:Daniel AC
-- Create date: 01-03-2018
-- Description:	Buscar el nombre del contrato por idcontrato 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_CD_ConsultarContratoPorIdContrato] 
	-- Add the parameters for the stored procedure here
	@IdContrato INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SELECT    distinct    C.NumeroContrato, AC.NombreAreaContractual, C.NumeroContrato + ' - ' + AC.NombreAreaContractual AS Contrato,
                          C.IdContrato, AC.IdAreaContractual
FROM            Adinco.dbo.CO_Contrato C
                 INNER JOIN
                         Adinco.dbo.CO_AreaContractual AC ON c.IdAreaContractual = AC.IdAreaContractual
WHERE        (C.IdContrato=@IdContrato)

END
