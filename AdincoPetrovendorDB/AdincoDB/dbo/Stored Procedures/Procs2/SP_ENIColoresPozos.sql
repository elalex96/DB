-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2020-07-09
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENIColoresPozos]
-- [dbo].[SP_ENIColoresPozos] 3,0
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

        -- Insert statements for procedure here
        SELECT DISTINCT 
               CASE
                   WHEN EP.Descripcion = 'PERFORACIÓN - TERMINACIÓN'
                   THEN 'PERFORADO Y TERMINADO'
                   ELSE EP.Descripcion
               END AS Descripcion, 
               EP.Color
        FROM dbo.CO_Instalacion I
             JOIN dbo.CO_ActividadCIEP A ON I.IdActividad = A.IdActividad
             JOIN dbo.CO_EstadoPozos EP ON EP.idEstatus = I.IdEstatus
             JOIN dbo.CO_AreaContractual AC ON I.IdAreaContractual = AC.IdAreaContractual
             JOIN dbo.CO_Contrato C ON AC.IdAreaContractual = C.IdAreaContractual
        WHERE C.IdContrato = @IdContrato
              AND A.IdActividad = 5;
    END;