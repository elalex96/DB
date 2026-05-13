-- =============================================
-- Author:        Reyna Olvera
-- Create date: 2018
-- Description:    Extrae Información del area contractual
-- =============================================
CREATE PROCEDURE sp_CO_ObtenerInfoAreaContractual
    @IdContrato INT=0,
    @IdUsuario INT=0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT NombreAreaContractual,
       SuperficieKm2,
       CASE C.GasNoAsociado
           WHEN 0 THEN
               1
           WHEN 1 THEN
               0
       END AS GasNoAsociado
FROM dbo.CO_AreaContractual AC
    JOIN dbo.CO_Contrato C
        ON C.IdAreaContractual = AC.IdAreaContractual
WHERE C.IdContrato =@IdContrato;
 

END
