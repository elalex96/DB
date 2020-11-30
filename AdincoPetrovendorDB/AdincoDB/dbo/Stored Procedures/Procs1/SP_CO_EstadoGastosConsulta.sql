-- =============================================
-- Author:		Manuel CD
-- Create date: 27-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_EstadoGastosConsulta]
    -- Add the parameters for the stored procedure here
    @EstadoRegistroID INT,
    @IdContrato INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here

    SELECT R.IdRegistro,
           CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN
                   R.IdFactura
               ELSE
                   R.IdPedimentoComprobante
           END AS IdFactura,
           R.MontoRegistro,
           CONVERT(CHAR(10), R.MesPresentacion, 103) AS MesPresentacion,
           CONVERT(CHAR(10), R.InicioEjecucion, 103) AS InicioEjecucion,
           CONVERT(CHAR(10), R.FinEjecucion, 103) AS FinEjecucion,
           R.Comentarios,
           R.Poliza,
           ER.NombreEstado AS Estado,
           I.NombreInstalacion,
           UC.Nombre AS CreadoPor,
           UM.Nombre AS ModificadoPor
    FROM CO_Registro AS R
        LEFT JOIN CO_LineaPresupuestoMes AS LPM
            ON R.IdPrograma = LPM.IdLineaPresupuestoMes
        LEFT JOIN CO_EstadoRegistro_V2 AS ER
            ON R.IdEstado = ER.IdClvEstado
        LEFT JOIN CO_Instalacion AS I
            ON R.IdInstalacion = I.IdInstalacion
        LEFT JOIN AP_Usuario UC
            ON R.IdUsuarioCreadoPor = UC.UsuarioID
        LEFT JOIN AP_Usuario UM
            ON R.IdUsuarioModPor = UM.UsuarioID
    WHERE R.IdRegistro = @EstadoRegistroID
          AND ER.IdContrato = @IdContrato;
END;
--SP_CO_EstadoGastosConsulta 11284,10007

