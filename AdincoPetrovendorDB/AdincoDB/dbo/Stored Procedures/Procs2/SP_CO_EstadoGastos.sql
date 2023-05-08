-- =============================================
-- Author:		Manuel CD
-- Create date: 27-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_EstadoGastos] 
	-- Add the parameters for the stored procedure here
@IdPresupuesto INT,
@IdUsuario     INT,
@IdContrato    INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here

    --     SELECT R.IdRegistro,
    --            R.IdFactura,
    --            R.MontoRegistro,
    --            CONVERT(CHAR(10),R.MesPresentacion,103) AS MesPresentacion,
    --            CONVERT(CHAR(10),R.InicioEjecucion,103) AS InicioEjecucion,
    --            CONVERT(CHAR(10),R.FinEjecucion,103) AS FinEjecucion,
    --            R.Comentarios,
    --            R.Poliza,
    --            ER.NombreEstado AS Estado,
    --            I.NombreInstalacion,
			 --UC.Nombre AS CreadoPor,
			 --UM.Nombre AS ModificadoPor
    --     FROM CO_Registro AS R
    --          INNER JOIN CO_LineaPresupuestoMes AS LPM ON R.IdPrograma = LPM.IdLineaPresupuestoMes
    --          INNER JOIN CO_EstadoRegistro_V2 AS ER ON R.IdEstado = ER.IdClvEstado
    --          INNER JOIN CO_Instalacion AS I ON R.IdInstalacion = I.IdInstalacion
		  --  INNER JOIN AP_Usuario UC ON R.IdUsuarioCreadoPor = UC.UsuarioID
		  --  INNER JOIN AP_Usuario UM ON R.IdUsuarioModPor = UM.UsuarioID
		  --  INNER JOIN CO_EstadoRegistroUsuario ERU ON ER.IdClvEstado = ERU.IdClvEstado
	   --WHERE LPM.IdPresupuesto = @IdPresupuesto
	   --AND ERU.IdUsuario = @IdUsuario
	   --AND ER.IdContrato = @IdContrato
	   --ORDER BY R.IdRegistro DESC

             SET NOCOUNT ON;
		   
/**/

             SELECT R.IdRegistro,
                    R.IdFactura,
                    S.NombreServicio AS Servicio,
                    I.NombreInstalacion AS InstalacionPresupuestada,
                    LPM.AC_FEC_INI AS FechaInicio,
                    LPM.AC_FEC_FIN AS FechaFin,
                    ER.NombreEstado AS Estado,
                    CASE
                        WHEN R.CvTipoDocFacturacion = 1
                        THEN 'CF'
                        WHEN R.CvTipoDocFacturacion = 2
                        THEN 'PI'
                        WHEN R.CvTipoDocFacturacion = 3
                        THEN 'PE'
                    END AS TipoDocumento,
                    CASE
                        WHEN R.CvTipoDocFacturacion = 1
                        THEN LTRIM(RTRIM(F.Serie+' '+F.Folio))
                        WHEN R.CvTipoDocFacturacion = 2
                        THEN PC.NumeroPedimento
                        WHEN R.CvTipoDocFacturacion = 3
                        THEN PC.FolioComprobante
                    END AS Numero,
                    CASE
                        WHEN R.CvTipoDocFacturacion = 1
                        THEN F.Fecha
                        WHEN R.CvTipoDocFacturacion IN(2, 3)
                        THEN PC.FechaPago
                    END AS FechaDocumento,
                    CASE
                        WHEN R.CvTipoDocFacturacion = 1
                        THEN SUM(CASE
                                     WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                     THEN ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio
                                     ELSE 0
                                 END)
                        WHEN R.CvTipoDocFacturacion IN(2, 3)
                        THEN SUM(CASE
                                     WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                     THEN ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio
                                     ELSE 0
                                 END)
                    END AS MontoUSD,
                    CASE
                        WHEN R.CvTipoDocFacturacion = 1
                        THEN SF.RazonSocial
                        WHEN R.CvTipoDocFacturacion IN(2, 3)
                        THEN SPC.RazonSocial
                    END AS Subcontratista,
                    IR.NombreInstalacion AS InstalacionRegistro,
                    R.InicioEjecucion,
                    R.FinEjecucion,
                    U.Nombre AS CreadoPor,
                    R.MontoRegistro,
                    CASE
                        WHEN R.CvTipoDocFacturacion = 1
                        THEN TMF.TipoMonedaCorto
                        WHEN R.CvTipoDocFacturacion IN(2, 3)
                        THEN TMPC.TipoMonedaCorto
                    END AS Moneda,
                    R.MesPresentacion AS MesPresentacion,
                    --dbo.CO_TipoServicio.NombreTipoServicio AS TipoDeServicio,-- dbo.CO_ActividadCIEP.NombreActividad AS Actividad,-- dbo.CO_SubactividadCIEP.NombreSubactividad AS SubActividad,
                    CASE
                        WHEN P.ciep = 1
                        THEN TS.NombreTipoServicio
                        ELSE ACNH.DescripcionActividadPetrolera
                    END AS TipoDeServicio,
                    CASE
                        WHEN P.ciep = 1
                        THEN ACIEP.NombreActividad
                        ELSE SAP.SubactividadPetrolera
                    END AS Actividad,
                    CASE
                        WHEN P.ciep = 1
                        THEN RI.NombreRubro
                        ELSE TP.TareaPetrolera
                    END AS SubActividad,
                    ER2.NombreEstado AS EstadoValidacion,
                    A.NombreArea AS Area,
                    R.Comentarios,
                    CA.ClasificacionAnexo4 AS Anexo4,
                    CASE
                        WHEN R.CvTipoDocFacturacion = 1
                        THEN F.IdFactura
                        WHEN R.CvTipoDocFacturacion IN(2, 3)
                        THEN PC.IdPedimentoComprobante
                    END AS Identificador,
                    LPM.IdLineaPresupuestoMes AS LineaPresupuesto,
                    P.Nombre AS Presupuesto,
                    IR.NombreInstalacion,
                    UC.Nombre AS CreadoPor,
                    UM.Nombre AS ModificadoPor,
                    R.Poliza
             FROM dbo.CO_LineaPresupuestoMes LPM
                  LEFT JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
                  LEFT JOIN dbo.CO_Instalacion I ON LPM.IdInstalacion = I.IdInstalacion
                  LEFT JOIN dbo.CO_Registro R ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                  LEFT JOIN dbo.FI_Factura F ON F.IdFactura = R.IdFactura
                  LEFT JOIN dbo.FI_pedimentocomprobante PC ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
                  LEFT JOIN dbo.PV_Subcontratista SF ON F.IdSubcontratista = SF.IdSubcontratista
                  LEFT JOIN dbo.PV_Subcontratista SPC ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
                  LEFT JOIN dbo.CO_Instalacion IR ON R.IdInstalacion = IR.IdInstalacion
                  LEFT JOIN dbo.AP_Usuario U ON R.IdUsuarioCreadoPor = U.UsuarioID
                  LEFT JOIN dbo.CO_TipoServicio TS ON LPM.IdTipoServicio = TS.IdTipoServicio
                  LEFT JOIN dbo.CO_ActividadCIEP ACIEP ON LPM.IdActividad = ACIEP.IdActividad
                  LEFT JOIN dbo.CO_SubactividadCIEP SCIEP ON LPM.IdSubactividad = SCIEP.IdSubactividad
                  LEFT JOIN dbo.CO_EstadoRegistro ER ON R.IdEstado = ER.IdEstadoRegistro
                  LEFT JOIN dbo.CO_Area A ON A.IdArea = LPM.IdArea
                  LEFT JOIN dbo.PV_TipoMoneda TMF ON TMF.IdMoneda = F.IdMoneda
                  LEFT JOIN dbo.CO_TipoCambioDiario TCDF ON TCDF.IdMoneda = TMF.IdMoneda
                                                            AND DAY(TCDF.Fecha) = DAY(F.Fecha)
                                                            AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
                                                            AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
                  LEFT JOIN dbo.PV_TipoMoneda TMPC ON TMPC.IdMoneda = PC.IdMoneda
                  LEFT JOIN dbo.CO_TipoCambioDiario TCDPC ON TCDPC.IdMoneda = TMPC.IdMoneda
                                                             AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
                                                             AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
                                                             AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)
                  LEFT JOIN dbo.CO_ClasificacionAnexo4 CA ON LPM.IdAnexo4 = CA.IdAnexo4
                  LEFT JOIN dbo.CO_Presupuesto P ON LPM.IdPresupuesto = P.IdPresupuesto
                  LEFT JOIN dbo.CO_ActividadPetroleraCNH ACNH ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
                  LEFT JOIN dbo.CO_SubactividadPetrolera SAP ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
                  LEFT JOIN dbo.CO_RubroInterno RI ON LPM.IdRubroInterno = RI.IdRubroInterno
                  LEFT JOIN dbo.CO_TareaPetrolera TP ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                  LEFT JOIN CO_EstadoRegistro_V2 AS ER2 ON R.IdEstado = ER2.IdClvEstado
                  JOIN AP_Usuario UC ON R.IdUsuarioCreadoPor = UC.UsuarioID
                  LEFT JOIN AP_Usuario UM ON R.IdUsuarioModPor = UM.UsuarioID
                  LEFT JOIN CO_EstadoRegistroUsuario ERU ON ER2.IdClvEstado = ERU.IdClvEstado
             WHERE --R.IdPrograma = 9
             (P.IdPresupuesto = @IdPresupuesto)
         
/*AND ((R.IdEstado = 10004
               AND @IdPresupuesto = 10000)
              OR (R.IdEstado IN(10000, 10001, 10002, 10003, 10004, 10005, 10006)
         AND @IdPresupuesto <> 10000))
              AND (R.IdRegistro IS NOT NULL)*/

             AND ER2.IdContrato = @IdContrato
             GROUP BY R.idfactura,
                      PC.NumeroPedimento,
                      S.NombreServicio,
                      I.NombreInstalacion,
                      LPM.AC_FEC_INI,
                      LPM.AC_FEC_FIN,
                      F.Fecha,
                      LTRIM(RTRIM(F.Serie+' '+F.Folio)),
                      SF.RazonSocial,
                      IR.NombreInstalacion,
                      R.InicioEjecucion,
                      R.FinEjecucion,
                      F.Fecha,
                      U.Nombre,
                      R.MontoRegistro,
                      TMF.TipoMonedaCorto,
                      R.MesPresentacion,
                      CASE
                          WHEN P.ciep = 1
                          THEN TS.NombreTipoServicio
                          ELSE ACNH.DescripcionActividadPetrolera
                      END,
                      CASE
                          WHEN P.ciep = 1
                          THEN ACIEP.NombreActividad
                          ELSE SAP.SubactividadPetrolera
                      END,
                      CASE
                          WHEN P.ciep = 1
                          THEN RI.NombreRubro
                          ELSE TP.TareaPetrolera
                      END,
                      R.IdRegistro,
                      ER.NombreEstado,
                      A.NombreArea,
                      R.Comentarios,
                      CA.ClasificacionAnexo4,
                      F.IdFactura,
                      PC.IdPedimentoComprobante,
                      IR.CUIP,
                      IR.WelIID,
                      LPM.IdLineaPresupuestoMes,
                      IR.IdInstalacion,
                      P.Nombre,
                      R.CvTipoDocFacturacion,
                      PC.FechaPago,
                      PC.IdMoneda,
                      R.IdRegistro,
                      PC.FolioComprobante,
                      SPC.RazonSocial,
                      TMPC.TipoMonedaCorto,
                      ER2.NombreEstado,
                      I.NombreInstalacion,
                      R.Poliza,
                      UC.Nombre,
                      UM.Nombre
             ORDER BY R.MesPresentacion DESC;
         END;