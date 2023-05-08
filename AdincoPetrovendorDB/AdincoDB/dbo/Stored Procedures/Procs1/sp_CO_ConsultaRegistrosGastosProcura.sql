CREATE PROCEDURE [dbo].[sp_CO_ConsultaRegistrosGastosProcura]
-- ============================================= 
@IdPresupuesto INT
AS
     BEGIN
         -- =============================================
         -- Author:		Miguel
         -- Create date: 
         -- Description:	
         -- =============================================
		 -- Author:		Reyna O.
         -- Create date: 30-06-2022
         -- Description: Se agrega NOLOCK, se eliminan comentarios y se mueven las creaciones 
		 -- de la tabla al inicio de procedure, se eliminan algunos Left y Joins innecesarios
		 -- =============================================
         SET NOCOUNT ON;
    
         CREATE TABLE #CartasProcura
         (IdFacutraP INT, 
          UUID       VARCHAR(100), 
          IdFacutraA INT
         );

         /**/
         CREATE TABLE #Datos
         (IdRegistro               INT, 
          Servicio                 VARCHAR(1000), 
          InstalacionPresupuestada VARCHAR(1000), 
          FechaInicio              DATE, 
          FechaFin                 DATE, 
          TipoDocumento            VARCHAR(100), 
          Numero                   VARCHAR(500), 
          FechaDocumento           DATETIME, 
          MontoUSD                 FLOAT, 
          Subcontratista           VARCHAR(1000), 
          InstalacionRegistro      VARCHAR(500), 
          InicioEjecucion          DATE, 
          FinEjecucion             DATE, 
          CreadoPor                VARCHAR(500), 
          MontoRegistro            FLOAT, 
          Moneda                   VARCHAR(50), 
          MesPresentacion          DATE, 
          TipoDeServicio           VARCHAR(500), 
          Actividad                VARCHAR(1000), 
          SubActividad             VARCHAR(1000), 
          EstadoValidacion         VARCHAR(500), 
          Area                     VARCHAR(500), 
          Comentarios              VARCHAR(5000), 
          Anexo4                   VARCHAR(500), 
          Identificador            INT, 
          LineaPresupuesto         INT, 
          Presupuesto              VARCHAR(1000), 
          Rubro                    VARCHAR(500), 
          PCN                      FLOAT, 
          CAA                      VARCHAR(500), 
          CCN                      VARCHAR(500), 
          ModificadoPor            VARCHAR(500),
		FacturaViaProcura            VARCHAR(500),
		NumeroPedido INT,
		Requision INT);

         /**/
         DECLARE @Contrato INT;
         SELECT @Contrato = PC.IdContrato
         FROM 
			dbo.CO_Presupuesto P (NOLOCK)
         JOIN 
			dbo.CO_ProgramaActividad PA (NOLOCK)
			ON	PA.IdProgramaActividad = P.IdProgramaActividad
			AND	P.IdPresupuesto = @IdPresupuesto
         JOIN 
			dbo.CO_PeriodoContrato PC (NOLOCK)
			ON PC.IdPeriodo = PA.IdPeriodoContrato
         WHERE P.IdPresupuesto = @IdPresupuesto;
         /**/

         INSERT INTO #CartasProcura
         (IdFacutraP, 
          UUID, 
          IdFacutraA
         )
                SELECT DISTINCT 
                       FP.IdFactura, 
                       FP.UUID, 
                       FA.IdFactura
                FROM 
					Petrovendor.dbo.MM_AceptacionCartaPCN AS AC (NOLOCK)
                     JOIN 
						Petrovendor.dbo.S_Documento_S3 AS D  (NOLOCK)
						ON D.IdDocumento = AC.IdDocumento
					    AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                     JOIN 
						Petrovendor.dbo.MM_AceptacionPedido AS AP  (NOLOCK)
						ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                     JOIN 
						Petrovendor.dbo.MM_Pedido AS P  (NOLOCK)
						ON P.IdPedido = AP.IdPedido
						AND P.IdContrato = @Contrato
                     JOIN 
						Petrovendor.dbo.S_Proveedor AS PR  (NOLOCK)
						ON PR.IdProveedor = P.IdSubcontratista
                     JOIN 
						Petrovendor.dbo.S_TipoValidacionDoc AS TD (NOLOCK)
						ON TD.IdTipoValidacionDoc = AC.IdEstatus
                     JOIN 
						Petrovendor.dbo.MM_Pedidos AS PG (NOLOCK)
						ON P.IdPedido = PG.IdIdentificador
                     LEFT JOIN 
						Petrovendor.dbo.MM_TipoPedido AS TP  (NOLOCK)
						ON TP.IdTipoPedido = PG.IdTipoPedido
                     LEFT JOIN
						Petrovendor.dbo.MM_AceptacionFactura AF  (NOLOCK)
						ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                     LEFT JOIN
						Petrovendor.dbo.FI_Factura FP  (NOLOCK)
						ON FP.IdFactura = AF.IdFactura
                     LEFT JOIN 
						Adinco.dbo.FI_Factura FA  (NOLOCK)
						ON FP.UUID = FA.UUID COLLATE DATABASE_DEFAULT
                WHERE AC.IdEstatus = 2
                      AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                      AND P.IdContrato = @Contrato
                      AND FP.UUID IS NOT NULL
                      AND FP.Activa = 1
                      AND ISNULL(FP.IsEliminado, 0) <> 1;

         /**/

         INSERT INTO #Datos
         (IdRegistro, 
          Servicio, 
          InstalacionPresupuestada, 
          FechaInicio, 
          FechaFin, 
          TipoDocumento, 
          Numero, 
          FechaDocumento, 
          MontoUSD, 
          Subcontratista, 
          InstalacionRegistro, 
          InicioEjecucion, 
          FinEjecucion, 
          CreadoPor, 
          MontoRegistro, 
          Moneda, 
          MesPresentacion, 
          TipoDeServicio, 
          Actividad, 
          SubActividad, 
          EstadoValidacion, 
          Area, 
          Comentarios, 
          Anexo4, 
          Identificador, 
          LineaPresupuesto, 
          Presupuesto, 
          Rubro, 
          PCN, 
          CAA, 
          CCN, 
          ModificadoPor,
		FacturaViaProcura,
		NumeroPedido,
		Requision
         )
                SELECT R.IdRegistro, 
                       S.NombreServicio AS Servicio, 
                       F.UUID,
                       LPM.AC_FEC_INI AS FechaInicio, 
                       LPM.AC_FEC_FIN AS FechaFin,
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
                       CASE
                           WHEN P.CIEP = 1
                           THEN TS.NombreTipoServicio
                           ELSE ACNH.DescripcionActividadPetrolera
                       END AS TipoDeServicio,
                       CASE
                           WHEN P.CIEP = 1
                           THEN ACIEP.NombreActividad
                           ELSE SAP.SubactividadPetrolera
                       END AS Actividad,
                       CASE
                           WHEN P.CIEP = 1
                           THEN RI.NombreRubro
                           ELSE TP.TareaPetrolera
                       END AS SubActividad, 
                       ER.NombreEstado AS EstadoValidacion, 
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
                       rubro.Descripcion AS Rubro, 
                       R.PCN,
                       CASE
                           WHEN R.CostosAtribuiblesAdministracion = 1
                           THEN 'SI'
                           ELSE 'NO'
                       END AS CAA,
                       CASE
                           WHEN WA.IdDocAwsDocAdinco IS NULL
                                AND R.CvTipoDocFacturacion = 1
                           THEN 'NO'
                           WHEN WA.IdDocAwsDocAdinco IS NULL
                                AND R.CvTipoDocFacturacion IN(2, 3)
                           THEN 'NA'
                           ELSE 'SI'
                       END AS CCN, 
                       UM.Nombre AS ModificadoPor,
				   ISNULL(FP.idfactura, 0) AS FacturaViaProcura,
				   POS.IdPedido AS NumeroPedido,
				   SOLPED.IdSolicitudPedido as Requision

                FROM 
					dbo.CO_LineaPresupuestoMes LPM	(NOLOCK)
                     LEFT JOIN dbo.CO_Servicio S (NOLOCK) ON LPM.IdServicio = S.IdServicio
                     LEFT JOIN dbo.CO_Instalacion I (NOLOCK) ON LPM.IdInstalacion = I.IdInstalacion
                     LEFT JOIN dbo.CO_Registro R  (NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     LEFT JOIN dbo.CO_GastosRubro rubro (NOLOCK) ON rubro.IdGastoRubro = R.IdGastoRubro
                     LEFT JOIN dbo.FI_Factura F (NOLOCK) ON F.IdFactura = R.IdFactura
                     LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK) ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
                     LEFT JOIN dbo.PV_Subcontratista SF (NOLOCK) ON F.IdSubcontratista = SF.IdSubcontratista
                     LEFT JOIN dbo.PV_Subcontratista SPC (NOLOCK) ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
                     LEFT JOIN dbo.CO_Instalacion IR (NOLOCK) ON R.IdInstalacion = IR.IdInstalacion
                     LEFT JOIN dbo.AP_Usuario U (NOLOCK) ON R.IdUsuarioCreadoPor = U.UsuarioID
                     LEFT JOIN dbo.CO_TipoServicio TS (NOLOCK) ON LPM.IdTipoServicio = TS.IdTipoServicio
                     LEFT JOIN dbo.CO_ActividadCIEP ACIEP (NOLOCK) ON LPM.IdActividad = ACIEP.IdActividad
                     LEFT JOIN dbo.CO_SubactividadCIEP SCIEP (NOLOCK) ON LPM.IdSubactividad = SCIEP.IdSubactividad
                     LEFT JOIN dbo.CO_EstadoRegistro ER (NOLOCK) ON R.IdEstado = ER.IdEstadoRegistro
                     LEFT JOIN dbo.CO_Area A (NOLOCK) ON A.IdArea = LPM.IdArea
                     LEFT JOIN dbo.PV_TipoMoneda TMF (NOLOCK) ON TMF.IdMoneda = F.IdMoneda
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDF (NOLOCK) ON TCDF.IdMoneda = TMF.IdMoneda
                                                               AND DAY(TCDF.Fecha) = DAY(F.Fecha)
                                                               AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
                                                               AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
                     LEFT JOIN dbo.PV_TipoMoneda TMPC (NOLOCK) ON TMPC.IdMoneda = PC.IdMoneda
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDPC (NOLOCK) ON TCDPC.IdMoneda = TMPC.IdMoneda
                                                                AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
                                                                AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
                                                                AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)
                     LEFT JOIN dbo.CO_ClasificacionAnexo4 CA (NOLOCK) ON LPM.IdAnexo4 = CA.IdAnexo4
                     LEFT JOIN dbo.CO_Presupuesto P  (NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto 
                     LEFT JOIN dbo.CO_ActividadPetroleraCNH ACNH (NOLOCK) ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
                     LEFT JOIN dbo.CO_SubactividadPetrolera SAP (NOLOCK) ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
                     LEFT JOIN dbo.CO_RubroInterno RI (NOLOCK) ON LPM.IdRubroInterno = RI.IdRubroInterno
                     LEFT JOIN dbo.CO_TareaPetrolera TP (NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                     LEFT JOIN dbo.AWS_DocAwsDocAdinco WA (NOLOCK) ON F.IdFactura = WA.IdDocAdinco
                     LEFT JOIN dbo.AP_Usuario UM (NOLOCK) ON R.IdUsuarioModPor = UM.UsuarioID
						LEFT JOIN Petrovendor.dbo.FI_FACTURA FP (NOLOCK) on F.UUID=FP.UUID collate Modern_Spanish_CI_AS
						LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF (NOLOCK) ON AF.IdFactura = FP.IdFactura
                        LEFT JOIN Petrovendor.dbo.TA_Operacion AS TAO (NOLOCK) ON TAO.IdDocumento = AF.IdAceptacionFactura ---OR TAO.IdDocumento = FAC.IdFactura
                        LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP (NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                        LEFT JOIN Petrovendor.dbo.MM_Pedido AS PO (NOLOCK) ON PO.IdPedido = AP.IdPedido
                        LEFT JOIN Petrovendor.dbo.MM_Pedidos AS POS (NOLOCK) ON POS.IdIdentificador = PO.IdPedido
                                                           AND POS.IdProveedorCliente = 863
                        LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido AS SOLPED (NOLOCK) ON SOLPED.IdSolicitudPedido = PO.IdSolicitudPedido
                        LEFT JOIN Petrovendor.dbo.S_Proveedor AS PC2 (NOLOCK) ON PC2.IdProveedor = SOLPED.IdProveedor
                        LEFT JOIN Petrovendor.dbo.S_Proveedor AS PV (NOLOCK) ON PV.IdProveedor = PO.IdSubcontratista
                        LEFT JOIN Petrovendor.dbo.CC_CentroCosto AS CC (NOLOCK) ON CC.IdCentroCosto = SOLPED.IdCentroCosto
                        LEFT JOIN Petrovendor.dbo.TA_TipoOperacion AS TAP (NOLOCK) ON TAP.IdTipoOperacion = TAO.IdTipoOperacion
                        LEFT JOIN Petrovendor.dbo.TA_Estatus AS ES (NOLOCK) ON ES.IdEstatus = TAO.IdEstatusOperacion
                        LEFT JOIN Petrovendor.dbo.PV_TipoMoneda AS TM (NOLOCK) ON TM.IdMoneda = FP.IdMoneda
                        LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TPED (NOLOCK) ON TPED.IdTipoPedido = POS.IdTipoPedido
                        LEFT JOIN Adinco.dbo.CO_Contrato AS ACC (NOLOCK) ON ACC.IdContrato = FP.IdContrato
                        LEFT JOIN Adinco.dbo.CO_AreaContractual AS AAC (NOLOCK) ON AAC.IdAreaContractual = ACC.IdAreaContractual
				   
                WHERE
						(P.IdPresupuesto = @IdPresupuesto)
				AND		
					(
						(R.IdEstado = 10004 AND		@IdPresupuesto = 10000)
						OR	(R.IdEstado IN(10000, 10001, 10002, 10003, 10004, 10005, 10006)	AND	@IdPresupuesto <> 10000)
					)
                AND		(R.IdRegistro IS NOT NULL)
                GROUP BY PC.NumeroPedimento, 
                         S.NombreServicio, 
                         F.UUID,
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
                             WHEN P.CIEP = 1
                             THEN TS.NombreTipoServicio
                             ELSE ACNH.DescripcionActividadPetrolera
                         END,
                         CASE
                             WHEN P.CIEP = 1
                             THEN ACIEP.NombreActividad
                             ELSE SAP.SubactividadPetrolera
                         END,
                         CASE
                             WHEN P.CIEP = 1
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
                         rubro.Descripcion, 
                         R.PCN,
                         CASE
                             WHEN R.CostosAtribuiblesAdministracion = 1
                             THEN 'SI'
                             ELSE 'NO'
                         END,
                         CASE
                             WHEN WA.IdDocAwsDocAdinco IS NULL
                                  AND R.CvTipoDocFacturacion = 1
                             THEN 'NO'
                             WHEN WA.IdDocAwsDocAdinco IS NULL
                                  AND R.CvTipoDocFacturacion IN(2, 3)
                             THEN 'NA'
                             ELSE 'SI'
                         END, 
                         UM.Nombre,
					 ISNULL(FP.idfactura, 0),
					 POS.IdPedido,
					  SOLPED.IdSolicitudPedido
                ORDER BY R.IdRegistro DESC;

         /**/

         UPDATE D
           SET 
               D.CCN = 'SI'
         FROM #Datos D	
              JOIN #CartasProcura CP 
			  ON D.Identificador = CP.IdFacutraA
         WHERE D.Identificador = CP.IdFacutraA
               AND D.TipoDocumento = 'CF';

         /**/

         SELECT IdRegistro, 
                Servicio, 
                InstalacionPresupuestada, 
                FechaInicio, 
                FechaFin, 
                TipoDocumento, 
                Numero, 
                FechaDocumento, 
                MontoUSD, 
				Subcontratista, 
                InstalacionRegistro, 
                InicioEjecucion, 
                FinEjecucion, 
                CreadoPor, 
                MontoRegistro, 
                Moneda, 
                MesPresentacion, 
                TipoDeServicio, 
                Actividad, 
                SubActividad, 
                EstadoValidacion, 
                Area, 
                Comentarios, 
                Anexo4, 
                Identificador, 
                LineaPresupuesto, 
                Presupuesto, 
                Rubro, 
                PCN, 
                CAA, 
                CCN, 
                ModificadoPor,
			 CASE FacturaViaProcura when 0 then 'NO' else 'SI' END as FacturaViaProcura,
			 ISNULL( NumeroPedido, 0) as NumeroPedido,
			 isnull( Requision,0) as Requision
         FROM #Datos;
     END;

