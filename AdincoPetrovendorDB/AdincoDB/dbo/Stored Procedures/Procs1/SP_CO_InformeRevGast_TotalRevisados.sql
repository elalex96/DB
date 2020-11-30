CREATE PROCEDURE [dbo].[SP_CO_InformeRevGast_TotalRevisados]
    @IdPresupuesto INT,
    @MesPresentacion DATE
AS
BEGIN
    SELECT CAST(SUM(USD) AS DECIMAL(10, 2)) AS TOTALRevisados
      FROM (   SELECT      CASE
                                WHEN R.CvTipoDocFacturacion = 1 THEN
                                    SUM(CASE
                                             WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN
                                                 ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio
                                             ELSE 0 END)
                                WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                                    SUM(CASE
                                             WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN
                                                 ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio
                                             ELSE 0 END) END AS USD
                 FROM      dbo.CO_LineaPresupuestoMes LPM
                 LEFT JOIN dbo.CO_Servicio S
                   ON LPM.IdServicio              = S.IdServicio
                 LEFT JOIN dbo.CO_Instalacion I
                   ON LPM.IdInstalacion           = I.IdInstalacion
                 LEFT JOIN dbo.CO_Registro R
                   ON R.IdPrograma                = LPM.IdLineaPresupuestoMes
                 LEFT JOIN dbo.FI_Factura F
                   ON F.IdFactura                 = R.IdFactura
                 LEFT JOIN dbo.FI_PedimentoComprobante PC
                   ON PC.IdPedimentoComprobante   = R.IdPedimentoComprobante
                 LEFT JOIN dbo.PV_Subcontratista SF
                   ON F.IdSubcontratista          = SF.IdSubcontratista
                 LEFT JOIN dbo.PV_Subcontratista SPC
                   ON SPC.IdSubcontratista        = PC.IdSubcontratistaExportador
                 LEFT JOIN dbo.CO_Instalacion IR
                   ON R.IdInstalacion             = IR.IdInstalacion
                 LEFT JOIN dbo.AP_Usuario U
                   ON R.IdUsuarioCreadoPor        = U.UsuarioID
                 LEFT JOIN dbo.CO_TipoServicio TS
                   ON LPM.IdTipoServicio          = TS.IdTipoServicio
                 LEFT JOIN dbo.CO_ActividadCIEP ACIEP
                   ON LPM.IdActividad             = ACIEP.IdActividad
                 LEFT JOIN dbo.CO_SubactividadCIEP SCIEP
                   ON LPM.IdSubactividad          = SCIEP.IdSubactividad
                 LEFT JOIN dbo.CO_EstadoRegistro ER
                   ON R.IdEstado                  = ER.IdEstadoRegistro
                 LEFT JOIN dbo.CO_Area A
                   ON A.IdArea                    = LPM.IdArea
                 LEFT JOIN dbo.PV_TipoMoneda TMF
                   ON TMF.IdMoneda                = F.IdMoneda
                 LEFT JOIN dbo.CO_TipoCambioDiario TCDF
                   ON TCDF.IdMoneda               = TMF.IdMoneda
                  AND DAY(TCDF.Fecha)             = DAY(F.Fecha)
                  AND MONTH(TCDF.Fecha)           = MONTH(F.Fecha)
                  AND YEAR(TCDF.Fecha)            = YEAR(F.Fecha)
                 LEFT JOIN dbo.PV_TipoMoneda TMPC
                   ON TMPC.IdMoneda               = PC.IdMoneda
                 LEFT JOIN dbo.CO_TipoCambioDiario TCDPC
                   ON TCDPC.IdMoneda              = TMPC.IdMoneda
                  AND DAY(TCDPC.Fecha)            = DAY(PC.FechaPago)
                  AND MONTH(TCDPC.Fecha)          = MONTH(PC.FechaPago)
                  AND YEAR(TCDPC.Fecha)           = YEAR(PC.FechaPago)
                 LEFT JOIN dbo.CO_ClasificacionAnexo4 CA
                   ON LPM.IdAnexo4                = CA.IdAnexo4
                 LEFT JOIN dbo.CO_Presupuesto P
                   ON LPM.IdPresupuesto           = P.IdPresupuesto
                 LEFT JOIN dbo.CO_ActividadPetroleraCNH ACNH
                   ON LPM.IdActividadPetrolera    = ACNH.IdActividadPetrolera
                 LEFT JOIN dbo.CO_SubactividadPetrolera SAP
                   ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
                 LEFT JOIN dbo.CO_RubroInterno RI
                   ON LPM.IdRubroInterno          = RI.IdRubroInterno
                 LEFT JOIN dbo.CO_TareaPetrolera TP
                   ON LPM.IdTareaPetrolera        = TP.IdTareaPetrolera
                INNER JOIN CO_EstadoRegistro_V2 AS ER2
                   ON R.IdEstado                  = ER2.IdClvEstado
                INNER JOIN AP_Usuario UC
                   ON R.IdUsuarioCreadoPor        = UC.UsuarioID
                INNER JOIN AP_Usuario UM
                   ON R.IdUsuarioModPor           = UM.UsuarioID
                INNER JOIN CO_EstadoRegistroUsuario ERU
                   ON ER2.IdClvEstado             = ERU.IdClvEstado
                WHERE --R.IdPrograma = 9

                           (P.IdPresupuesto  = @IdPresupuesto)
                  AND      (   (   R.IdEstado     = 10004
                             AND   @IdPresupuesto = 10000)
                          OR   (   R.IdEstado IN ( 10000, 10001, 10002, 10003, 10004, 10005, 10006 )
                             AND   @IdPresupuesto   <> 10000))
                  AND      (R.IdRegistro IS NOT NULL)
                  AND      R.MesPresentacion      = @MesPresentacion
                GROUP BY R.IdFactura,
                         TS.NombreTipoServicio,
                         ACIEP.NombreActividad,
                         R.IdFactura,
                         F.Serie,
                         F.Folio,
                         F.FechaTimbrado,
                         F.Moneda,
                         F.SubTotal,
                         F.TipoCambio,
                         R.MontoRegistro,
                         SF.RazonSocial,
                         PC.NumeroPedimento,
                         S.NombreServicio,
                         I.NombreInstalacion,
                         LPM.AC_FEC_INI,
                         LPM.AC_FEC_FIN,
                         F.Fecha,
                         LTRIM(RTRIM(F.Serie + ' ' + F.Folio)),
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
                              WHEN P.CIEP = 1 THEN TS.NombreTipoServicio
                              ELSE ACNH.DescripcionActividadPetrolera END,
                         CASE
                              WHEN P.CIEP = 1 THEN ACIEP.NombreActividad
                              ELSE SAP.SubactividadPetrolera END,
                         CASE
                              WHEN P.CIEP = 1 THEN RI.NombreRubro
                              ELSE TP.TareaPetrolera END,
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
                         ER.NombreEstado,
                         I.NombreInstalacion,
                         R.Poliza,
                         UC.Nombre,
                         UM.Nombre) SRC;
END;

