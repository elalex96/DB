-- =============================================
-- Author:		Marcos Garcia
-- Create date: 07-02-2020
-- Description: Consulta Todos Los Contratos
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaContratosPorContratistaAdminPCN]
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT IdContrato, 
               NumeroContrato
        FROM dbo.CO_Contrato
        WHERE ISNULL(Activo, 0) = 1
        ORDER BY IdContrato ASC;
    END;
