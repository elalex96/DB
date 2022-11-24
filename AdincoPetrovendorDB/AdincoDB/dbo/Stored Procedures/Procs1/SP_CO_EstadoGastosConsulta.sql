-- =============================================
-- Author:		Manuel CD
-- Create date: 27-09-17
-- Description:	
-- =============================================
-- Modificado Por:		Neri del Angel
-- Fecha Modificación:	07 de Septiembre del 2022
-- Descripción:			Se agrega el join de la tabla CO_RegistroMarkup
--						para obtener las fechas de MesEstadoPemex 
--						el cual sirve para pre llenar el mes selecionado en alguna otra edicion
-- ========================================================================
CREATE PROCEDURE [dbo].[SP_CO_EstadoGastosConsulta]
    @EstadoRegistroID INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
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
           UM.Nombre AS ModificadoPor,
           CO_RegistroMarkup.MesEstadoPemex,
           CAST(CO_RegistroMarkup.MesEstadoPemex AS DATE) AS IdFecha,
           CONCAT(datename(month, CO_RegistroMarkup.MesEstadoPemex), ' ', YEAR(CO_RegistroMarkup.MesEstadoPemex)) AS Fecha
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
        LEFT JOIN CO_RegistroMarkup
            ON R.IdRegistro = CO_RegistroMarkup.GastoId
    WHERE R.IdRegistro = @EstadoRegistroID
          AND ER.IdContrato = @IdContrato;
END;
