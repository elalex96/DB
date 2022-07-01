-- =============================================
-- Author:		Marcos Neri
-- Create date: 10-01-2020
-- Description:	*Agregar columna IdEstado
-- =============================================
-- Author:		 Marcos Garcia
-- Alter date:	 01-09-2021
-- Description: Add Cat Mano de Obra
-- =============================================
-- Author:		 Daniel Moreno
-- Alter date:	 05-04-2021
-- Description: Se agregan filtros de fechas
CREATE PROCEDURE [dbo].[SP_CO_ConsultaAllRegistrosGastos]
-- ============================================= 
-- [SP_CO_ConsultaAllRegistrosGastos] 3,10002
@IdContrato INT, 
@IdUsuario  INT,
@FechaDel DATETIME = NULL,
@FechaAl DATETIME = NULL
AS
     BEGIN
         -- =============================================
         -- Author:			Marcos Garcia
         -- Create date:	06-01-2020
         -- Description:	Seleciona todos los registro de gastos del Contrato
         -- =============================================
         SET NOCOUNT ON;
         --=====================================================
         IF OBJECT_ID('tempdb..#TPeriodos', 'U') IS NOT NULL
             DROP TABLE #TPeriodos;
         IF OBJECT_ID('tempdb..#TPresuspuestos', 'U') IS NOT NULL
             DROP TABLE #TPresuspuestos;
         IF OBJECT_ID('tempdb..#CartasProcura', 'U') IS NOT NULL
             DROP TABLE #CartasProcura;
         IF OBJECT_ID('tempdb..#Datos', 'U') IS NOT NULL
             DROP TABLE #Datos;
         --=====================================================
         CREATE TABLE #TPeriodos
         (IdPeriodo         INT, 
          NombreParaMostrar VARCHAR(1500)
         );
         /**/
         CREATE TABLE #TPresuspuestos
         (IdProgramaActividad     INT, 
          IdPeriodoContrato       INT, 
          IdTipoProgramaActividad INT, 
          NombrePrograma          VARCHAR(1500), 
          IdContrato              INT, 
          NombrePeriodo			  VARCHAR(1500), 
          Inicio                  DATE, 
          Fin                     DATE, 
          IdPresupuesto           INT, 
          Nombre                  VARCHAR(1500)
         );
         --=====================================================
         CREATE TABLE #CartasProcura
         (IdFacutraP INT, 
          UUID       VARCHAR(150), 
          IdFacutraA INT);

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
          NombrePresupuesto        VARCHAR(1000), 
          Rubro                    VARCHAR(500),
		  CatManoObra			   VARCHAR(500), 
          PCN                      FLOAT, 
          CAA                       VARCHAR(500), 
          CCN                       VARCHAR(500), 
          ModificadoPor             VARCHAR(500), 
          CreacionGasto            DATE, 
          IdEstado                 INT,
		  UUID						VARCHAR(200)
         );

         /**/
        INSERT INTO #TPeriodos
         (IdPeriodo, 
          NombreParaMostrar
         )
                SELECT IdPeriodo, 
                       NombrePeriodo AS NombreParaMostrar
                FROM 
					CO_PeriodoContrato
                WHERE
					(IdContrato = @IdContrato);
         /**/

        INSERT INTO #TPresuspuestos
         (IdProgramaActividad, 
          IdPeriodoContrato, 
          IdTipoProgramaActividad, 
          NombrePrograma, 
          IdContrato, 
          NombrePeriodo, 
          Inicio, 
          Fin, 
          IdPresupuesto, 
          Nombre
         )
                SELECT CO_ProgramaActividad.IdProgramaActividad, 
                       CO_ProgramaActividad.IdPeriodoContrato, 
                       CO_ProgramaActividad.IdTipoProgramaActividad, 
                       CO_ProgramaActividad.NombrePrograma, 
                       CO_PeriodoContrato.IdContrato, 
                       CO_PeriodoContrato.NombrePeriodo, 
                       CO_PeriodoContrato.Inicio, 
                       CO_PeriodoContrato.Fin, 
                       CO_Presupuesto.IdPresupuesto, 
                       CO_Presupuesto.Nombre+'['+CO_Presupuesto.IdPresupuestoCNH+']' AS Nombre
                FROM 
					CO_ProgramaActividad
				INNER JOIN 
					CO_PeriodoContrato	(NOLOCK)
					ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
				INNER JOIN 
					#TPeriodos			(NOLOCK)
					ON #TPeriodos.IdPeriodo = CO_PeriodoContrato.IdPeriodo
				INNER JOIN 
					CO_Presupuesto		(NOLOCK)
					ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
                WHERE 
					CO_Presupuesto.Activo = 1;
        
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
          NombrePresupuesto, 
          Rubro, 
		  CatManoObra,
          PCN, 
          CAA, 
          CCN, 
          ModificadoPor, 
          CreacionGasto, 
          IdEstado,
		  UUID
         )
                SELECT 
					   R.IdRegistro, 
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
                       TPre.Nombre AS NombrePresupuesto, 
                       rubro.Descripcion AS Rubro, 
					   catmo.Nombre AS CatManoObra, 
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
                       CAST(R.FecMovto AS DATE) AS CreacionGasto, 
                       R.IdEstado,
					    F.UUID
                FROM 
						#TPresuspuestos TPre
				INNER JOIN	
						dbo.CO_LineaPresupuestoMes LPM		(NOLOCK)	
						ON TPre.IdPresupuesto = LPM.IdPresupuesto			 					 
				INNER JOIN 
						dbo.CO_Registro R					(NOLOCK)
						ON	
							(
								(@FechaDel IS NOT NULL AND @FechaAl IS NOT NULL AND R.MesPresentacion BETWEEN @FechaDel AND @FechaAl)
								OR
								(@FechaDel IS NULL AND @FechaAl IS NULL)
							) AND
							R.IdPrograma = LPM.IdLineaPresupuestoMes AND 
							R.IdRegistro IS NOT NULL  AND
							(
								(
									R.IdEstado = 10004
									AND TPre.IdPresupuesto = 10000
								)
								OR 
								(
									R.IdEstado IN(10000, 10001, 10002, 10003, 10004, 10005, 10006)
									AND TPre.IdPresupuesto <> 10000
								)
							) 
					 INNER JOIN 
							dbo.CO_Presupuesto P				(NOLOCK)
							ON LPM.IdPresupuesto = P.IdPresupuesto					 
                     LEFT JOIN 
							dbo.CO_Servicio S					(NOLOCK)
							ON LPM.IdServicio = S.IdServicio
                     LEFT JOIN 
							dbo.CO_Instalacion I				(NOLOCK)
							ON LPM.IdInstalacion = I.IdInstalacion
                     LEFT JOIN 
							dbo.CO_GastosRubro rubro			(NOLOCK)
							ON rubro.IdGastoRubro = R.IdGastoRubro
					 LEFT JOIN 
							dbo.CO_CAT_ManoDeObra catmo			(NOLOCK) 
							ON catmo.Id = R.IdCatManoObra
                     LEFT JOIN 
							dbo.FI_Factura F					(NOLOCK)
							ON F.IdFactura = R.IdFactura
                     LEFT JOIN 
							dbo.FI_PedimentoComprobante PC		(NOLOCK)
							ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
                     LEFT JOIN 
							dbo.PV_Subcontratista SF			(NOLOCK)
							ON F.IdSubcontratista = SF.IdSubcontratista
                     LEFT JOIN 
							dbo.PV_Subcontratista SPC			(NOLOCK)
							ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
                     LEFT JOIN 
							dbo.CO_Instalacion IR				(NOLOCK)
							ON R.IdInstalacion = IR.IdInstalacion
                     LEFT JOIN 
							dbo.AP_Usuario U					(NOLOCK)
							ON R.IdUsuarioCreadoPor = U.UsuarioID
                     LEFT JOIN 
							dbo.CO_TipoServicio TS				(NOLOCK)
							ON LPM.IdTipoServicio = TS.IdTipoServicio
                     LEFT JOIN 
							dbo.CO_ActividadCIEP ACIEP			(NOLOCK)
							ON LPM.IdActividad = ACIEP.IdActividad
                     LEFT JOIN 
							dbo.CO_SubactividadCIEP SCIEP		(NOLOCK)
							ON LPM.IdSubactividad = SCIEP.IdSubactividad
                     LEFT JOIN 
							dbo.CO_EstadoRegistro ER			(NOLOCK)
							ON R.IdEstado = ER.IdEstadoRegistro
                     LEFT JOIN 
							dbo.CO_Area A						(NOLOCK)
							ON A.IdArea = LPM.IdArea
                     LEFT JOIN 
							dbo.PV_TipoMoneda TMF				(NOLOCK)
							ON TMF.IdMoneda = F.IdMoneda
                     LEFT JOIN 
							dbo.CO_TipoCambioDiario TCDF		(NOLOCK)
							ON TCDF.IdMoneda = TMF.IdMoneda
							AND DAY(TCDF.Fecha) = DAY(F.Fecha)
							AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
							AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
                     LEFT JOIN 
							dbo.PV_TipoMoneda TMPC				(NOLOCK)
							ON TMPC.IdMoneda = PC.IdMoneda
                     LEFT JOIN 
							dbo.CO_TipoCambioDiario TCDPC		(NOLOCK)
							ON TCDPC.IdMoneda = TMPC.IdMoneda
							AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
							AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
							AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)
                     LEFT JOIN 
							dbo.CO_ClasificacionAnexo4 CA		(NOLOCK)
							ON LPM.IdAnexo4 = CA.IdAnexo4                    
                     LEFT JOIN 
							dbo.CO_ActividadPetroleraCNH ACNH	(NOLOCK)
							ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
                     LEFT JOIN 
							dbo.CO_SubactividadPetrolera SAP	(NOLOCK)
							ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
                     LEFT JOIN 
							dbo.CO_RubroInterno RI				(NOLOCK)
							ON LPM.IdRubroInterno = RI.IdRubroInterno
                     LEFT JOIN 
							dbo.CO_TareaPetrolera TP			(NOLOCK)
							ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                     LEFT JOIN 
							dbo.AWS_DocAwsDocAdinco WA			(NOLOCK)
							ON F.IdFactura = WA.IdDocAdinco
                     LEFT JOIN 
							dbo.AP_Usuario UM					(NOLOCK)
							ON R.IdUsuarioModPor = UM.UsuarioID
				
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
                         TPre.Nombre, 
                         R.CvTipoDocFacturacion, 
                         PC.FechaPago, 
                         PC.IdMoneda, 
                         R.IdRegistro, 
                         PC.FolioComprobante, 
                         SPC.RazonSocial, 
                         TMPC.TipoMonedaCorto, 
                         rubro.Descripcion,
						 catmo.Nombre,
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
                         CAST(R.FecMovto AS DATE), 
                         R.IdEstado
                ORDER BY R.IdRegistro DESC;
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
					#Datos datos
				JOIN 
					Petrovendor.dbo.FI_Factura FP	(NOLOCK)
					ON FP.UUID = datos.UUID COLLATE DATABASE_DEFAULT	 AND
													FP.UUID IS NOT NULL AND 
													FP.Activa = 1 AND
													ISNULL(FP.IsEliminado, 0) <> 1
				JOIN 
					Adinco.dbo.FI_Factura FA	(NOLOCK)
					ON FP.UUID = FA.UUID COLLATE DATABASE_DEFAULT	 
				JOIN 
					Petrovendor.dbo.MM_AceptacionFactura AF	(NOLOCK)
					ON AF.IdFactura = FP.IdFactura
				JOIN 
					Petrovendor.dbo.MM_AceptacionPedido AS AP	(NOLOCK)
					ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				JOIN 
					Petrovendor.dbo.MM_AceptacionCartaPCN AS AC	(NOLOCK)
					ON AC.IdAceptacionPedido = AP.IdAceptacionPedido AND 
					AC.IdEstatus = 2 AND
					ISNULL(AC.IdEstatusEliminado, 0) <> 1
				JOIN 
					Petrovendor.dbo.S_Documento_S3 AS D	(NOLOCK)
					ON D.IdDocumento = AC.IdDocumento
				JOIN 
					Petrovendor.dbo.MM_Pedido AS P	(NOLOCK)
					ON P.IdPedido = AP.IdPedido AND 
					P.IdContrato = @IdContrato
				JOIN 
					Petrovendor.dbo.S_Proveedor AS PR	(NOLOCK)
					ON PR.IdProveedor = P.IdSubcontratista
				JOIN 
					Petrovendor.dbo.S_TipoValidacionDoc AS TD	(NOLOCK)
					ON TD.IdTipoValidacionDoc = AC.IdEstatus
				JOIN 
					Petrovendor.dbo.MM_Pedidos AS PG	(NOLOCK)
					ON P.IdPedido = PG.IdIdentificador	
				JOIN 
					Petrovendor.dbo.MM_TipoPedido AS TP	(NOLOCK)
					ON TP.IdTipoPedido = PG.IdTipoPedido                     					 
        /**/
         UPDATE D
           SET 
               D.CCN = 'SI'
         FROM #Datos D
              JOIN 
				#CartasProcura CP	(NOLOCK)
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
                NombrePresupuesto, 
                Rubro, 
			    CatManoObra,
                PCN, 
                CAA, 
                CCN, 
                ModificadoPor, 
                CreacionGasto, 
                IdEstado
         FROM #Datos
		 ORDER BY MesPresentacion DESC;
     END;


