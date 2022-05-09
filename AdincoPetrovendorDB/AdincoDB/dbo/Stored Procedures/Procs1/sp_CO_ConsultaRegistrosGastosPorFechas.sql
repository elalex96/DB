GO
CREATE PROCEDURE [dbo].[sp_CO_ConsultaRegistrosGastosPorFechas]
-- ============================================= 
@FechaMes DATETIME,
@IdContrato INT,
@IdUsuario INT
AS
     BEGIN
	 DECLARE @FechaInicio DATETIME,@FechaFin  DATETIME;
         -- =============================================
         -- Author:		Miguel
         -- Create date: 
         -- Description:	
         -- =============================================
         -- Author:		Marcos Garcia
         -- Alter date:	05-02-2020
         -- Description: Agregar NOLOCK
         -- =============================================
		 -- Author:		 Marcos Garcia
         -- Alter date:	 01-09-2021
         -- Description: Add Cat Mano de Obra
         -- =============================================
		 -- Author:		 Reyna Olvera
         -- Alter date:	 26-04-2022
         -- Description: Se agrega validación del día 06 del mes siguiente
         -- =============================================
         SET NOCOUNT ON;
         SET LANGUAGE spanish;

         /**/
		 DECLARE @DiaActual DATE = GETDATE();
     
	 /*    DECLARE @Contrato INT;
         SELECT @Contrato = PC.IdContrato
         FROM dbo.CO_Presupuesto P
              JOIN dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
              JOIN dbo.CO_PeriodoContrato PC ON PC.IdPeriodo = PA.IdPeriodoContrato
         WHERE ((P.IdPresupuesto = @IdPresupuesto) or @IdPresupuesto = -1)
		 --select @Contrato
         /**/
		 */
         CREATE TABLE	#CartasProcura
         (
			IdFacutraP		int, 
			UUID			nvarchar(100), 
			IdFactura		int
         );

		 
		 CREATE TABLE	#MesesAnio
         (
			Id	INT IDENTITY(1,1),
			PrimerDiaMes DATE,
			UltimoDiaMes DATE,
			SiguienteMesSeis DATE
         );
         /**/

         CREATE TABLE #Datos
         (IdRegistro               INT, 
          Servicio                 NVARCHAR(MAX), 
          InstalacionPresupuestada NVARCHAR(MAX), 
          FechaInicio              DATE, 
          FechaFin                 DATE, 
          TipoDocumento            NVARCHAR(MAX), 
          Numero                   NVARCHAR(MAX), 
          FechaDocumento           DATETIME, 
          MontoUSD                 FLOAT, 
          Subcontratista           NVARCHAR(MAX), 
          InstalacionRegistro      NVARCHAR(MAX), 
          InicioEjecucion          DATE, 
          FinEjecucion             DATE, 
          CreadoPor                NVARCHAR(MAX), 
          MontoRegistro            FLOAT, 
          Moneda                   NVARCHAR(MAX), 
          MesPresentacion          DATE, 
          Anio                     INT, 
          Mes                      NVARCHAR(MAX), 
          TipoDeServicio           NVARCHAR(MAX), 
          Actividad                NVARCHAR(MAX), 
          SubActividad             NVARCHAR(MAX), 
          EstadoValidacion         NVARCHAR(MAX), 
          Area                     NVARCHAR(MAX), 
          Comentarios              NVARCHAR(MAX), 
          Anexo4                   NVARCHAR(MAX), 
          Identificador            INT, 
          LineaPresupuesto         INT, 
          Presupuesto              NVARCHAR(MAX), 
          Rubro                    NVARCHAR(MAX), 
		  CatManoObra			   NVARCHAR(MAX), 
          PCN                      FLOAT, 
          CAA                      NVARCHAR(MAX), 
          CCN                      NVARCHAR(MAX), 
          ModificadoPor            NVARCHAR(MAX)
         );
		  /**/


         /**/

         INSERT INTO #CartasProcura
         (IdFacutraP, 
          UUID, 
          IdFactura
         )
                SELECT DISTINCT 
                       FP.IdFactura, 
                       FP.UUID, 
                       FA.IdFactura
                FROM		Petrovendor.dbo.MM_AceptacionCartaPCN	AS AC(NOLOCK)
                Inner JOIN	Petrovendor.dbo.S_Documento_S3			AS D(NOLOCK)  ON D.IdDocumento			= AC.IdDocumento
                Inner JOIN	Petrovendor.dbo.MM_AceptacionPedido		AS AP(NOLOCK) ON AP.IdAceptacionPedido	= AC.IdAceptacionPedido
                Inner JOIN	Petrovendor.dbo.MM_Pedido				AS P (NOLOCK) ON P.IdPedido				= AP.IdPedido
                Inner JOIN	Petrovendor.dbo.S_Proveedor				AS PR(NOLOCK) ON PR.IdProveedor			= P.IdSubcontratista
                Inner JOIN	Petrovendor.dbo.S_TipoValidacionDoc		AS TD(NOLOCK) ON TD.IdTipoValidacionDoc = AC.IdEstatus
                Inner JOIN	Petrovendor.dbo.MM_Pedidos				AS PG(NOLOCK) ON P.IdPedido				= PG.IdIdentificador
                LEFT JOIN	Petrovendor.dbo.MM_TipoPedido			AS TP(NOLOCK) ON TP.IdTipoPedido		= PG.IdTipoPedido
                LEFT JOIN	Petrovendor.dbo.MM_AceptacionFactura	as AF(NOLOCK) ON AF.IdAceptacionPedido	= AP.IdAceptacionPedido
                LEFT JOIN	Petrovendor.dbo.FI_Factura				as FP(NOLOCK) ON FP.IdFactura			= AF.IdFactura
                LEFT JOIN	Adinco.dbo.FI_Factura					as FA(NOLOCK) ON FP.UUID				= FA.UUID COLLATE DATABASE_DEFAULT
                WHERE		AC.IdEstatus = 2
                AND			ISNULL(AC.IdEstatusEliminado, 0)	<>	1
                AND			P.IdContrato						=	@IdContrato
                AND			FP.UUID								IS	NOT NULL
                AND			FP.Activa							=	1
                AND			ISNULL(FP.IsEliminado, 0)			<>	1--*******

         /**/
		 -- NUEVA VALIDACIÓN PARA QUE PEMEX NO VEA LOS GASTOS UN NO APROBADOS HASTA EL SIGUIENTE MES DÍA 6 (ISSUE 1891)
		INSERT INTO #MesesAnio(PrimerDiaMes,UltimoDiaMes)
		 SELECT DISTINCT PrimerDiaMes, UltimoDiaMes  -- se buscan el primer día y el ultimo día del mes seleccionado, ya que se encontraron gastos con día del mes presentación mayor a 1
		 FROM AP_Calendario 
		 WHERE IdFecha = @FechaMes
		 ORDER BY UltimoDiaMes	DESC;


		UPDATE #MesesAnio 
		SET SiguienteMesSeis =  DATEFROMPARTS(YEAR(DATEADD(MONTH, 1, PrimerDiaMes)),MONTH(DATEADD(MONTH, 1, PrimerDiaMes)),6);

		 DELETE FROM #MesesAnio WHERE SiguienteMesSeis > @DiaActual; --SE BORRAN EL MES QUE AUN NO SE PUEDE MOSTRAR HASTA DESPUES DEL DÍA 6 DEL SIGUIENTE MES

		 IF((SELECT COUNT(1) FROM #MesesAnio) > 0)
		 BEGIN
		 
		 SELECT @FechaInicio = MIN(PrimerDiaMes),@FechaFin= MAX(UltimoDiaMes) FROM #MesesAnio;
		
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
          Anio, 
          Mes, 
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
		  CatManoObra,
          PCN, 
          CAA, 
          CCN, 
          ModificadoPor
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
                       YEAR(R.MesPresentacion) AS Anio, 
                       CONCAT(RIGHT('00'+CAST(MONTH(R.MesPresentacion) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, R.MesPresentacion)) AS Mes, 
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
                       UM.Nombre AS ModificadoPor
                FROM  
					dbo.CO_PeriodoContrato PEC
					LEFT JOIN 
						dbo.CO_ProgramaActividad PA
						 ON PEC.IdPeriodo = PA.IdPeriodoContrato
						 AND PEC.IdContrato = @IdContrato
				    LEFT JOIN 
						dbo.CO_Presupuesto P(NOLOCK)
						ON PA.IdProgramaActividad = P.IdProgramaActividad
					LEFT JOIN 
						dbo.CO_LineaPresupuestoMes LPM(NOLOCK)
						ON P.IdPresupuesto =	LPM.IdPresupuesto 
					 LEFT JOIN dbo.CO_Servicio S(NOLOCK) ON LPM.IdServicio = S.IdServicio
                     LEFT JOIN dbo.CO_Instalacion I(NOLOCK) ON LPM.IdInstalacion = I.IdInstalacion
                     LEFT JOIN dbo.CO_Registro R(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                     LEFT JOIN dbo.CO_GastosRubro rubro(NOLOCK) ON rubro.IdGastoRubro = R.IdGastoRubro
					 LEFT JOIN dbo.CO_CAT_ManoDeObra catmo(NOLOCK) ON catmo.Id = R.IdCatManoObra
                     LEFT JOIN dbo.FI_Factura F(NOLOCK) ON F.IdFactura = R.IdFactura
                     LEFT JOIN dbo.FI_PedimentoComprobante PC(NOLOCK) ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
                     LEFT JOIN dbo.PV_Subcontratista SF(NOLOCK) ON F.IdSubcontratista = SF.IdSubcontratista
					 LEFT JOIN dbo.PV_Subcontratista SPC(NOLOCK) ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
					 LEFT JOIN dbo.CO_Instalacion IR(NOLOCK) ON R.IdInstalacion = IR.IdInstalacion
                     LEFT JOIN dbo.AP_Usuario U(NOLOCK) ON R.IdUsuarioCreadoPor = U.UsuarioID
                     LEFT JOIN dbo.CO_TipoServicio TS(NOLOCK) ON LPM.IdTipoServicio = TS.IdTipoServicio
                     LEFT JOIN dbo.CO_ActividadCIEP ACIEP(NOLOCK) ON LPM.IdActividad = ACIEP.IdActividad
                     LEFT JOIN dbo.CO_SubactividadCIEP SCIEP(NOLOCK) ON LPM.IdSubactividad = SCIEP.IdSubactividad
                     LEFT JOIN dbo.CO_EstadoRegistro ER(NOLOCK) ON R.IdEstado = ER.IdEstadoRegistro
                     LEFT JOIN dbo.CO_Area A(NOLOCK) ON A.IdArea = LPM.IdArea
                     LEFT JOIN dbo.PV_TipoMoneda TMF(NOLOCK) ON TMF.IdMoneda = F.IdMoneda
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDF(NOLOCK) ON TCDF.IdMoneda = TMF.IdMoneda
                                                                       AND DAY(TCDF.Fecha) = DAY(F.Fecha)
                                                                       AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
                                                                       AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
                     LEFT JOIN dbo.PV_TipoMoneda TMPC(NOLOCK) ON TMPC.IdMoneda = PC.IdMoneda
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDPC(NOLOCK) ON TCDPC.IdMoneda = TMPC.IdMoneda
                                                                        AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
                                                                        AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
                                                                        AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)
                     LEFT JOIN dbo.CO_ClasificacionAnexo4 CA(NOLOCK) ON LPM.IdAnexo4 = CA.IdAnexo4
                   
                     LEFT JOIN dbo.CO_ActividadPetroleraCNH ACNH(NOLOCK) ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
                     LEFT JOIN dbo.CO_SubactividadPetrolera SAP(NOLOCK) ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
                     LEFT JOIN dbo.CO_RubroInterno RI(NOLOCK) ON LPM.IdRubroInterno = RI.IdRubroInterno
     LEFT JOIN dbo.CO_TareaPetrolera TP(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                     LEFT JOIN dbo.AWS_DocAwsDocAdinco WA(NOLOCK) ON F.IdFactura = WA.IdDocAdinco
                     LEFT JOIN dbo.AP_Usuario UM(NOLOCK) ON R.IdUsuarioModPor = UM.UsuarioID
                WHERE 
					(PEC.IdContrato = @IdContrato)
                AND (R.IdRegistro IS NOT NULL)
				AND (R.MesPresentacion BETWEEN CAST(@FechaInicio AS DATE) AND  CAST(@FechaFin AS DATE))
                GROUP BY PC.NumeroPedimento, 
                         S.NombreServicio, 
                         F.UUID, --I.NombreInstalacion, 
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
       YEAR(R.MesPresentacion), 
                         CONCAT(RIGHT('00'+CAST(MONTH(R.MesPresentacion) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, R.MesPresentacion)), 
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
                         UM.Nombre
                ORDER BY R.IdRegistro DESC;

         
			UPDATE	#Datos--D
			SET		#Datos.CCN		=	'SI'
			FROM	#Datos			D
			JOIN	#CartasProcura	CP 
			ON		D.Identificador =	CP.IdFactura
			WHERE	D.Identificador =	CP.IdFactura
			AND		D.TipoDocumento =	'CF';
		
		
		END

         SELECT		--top 30
					d.IdRegistro, --',',
					d.Servicio, 
					d.InstalacionPresupuestada, 
					d.FechaInicio, 
					d.FechaFin, 
					d.TipoDocumento, 
					d.Numero, 
					d.FechaDocumento, 
					d.MontoUSD, 
					d.Subcontratista, 
					d.InstalacionRegistro, 
					d.InicioEjecucion, 
					d.FinEjecucion, 
					d.CreadoPor, 
					d.MontoRegistro, 
					d.Moneda, 
					d.MesPresentacion, 
					d.Anio, 
					d.Mes, 
					d.TipoDeServicio, 
					d.Actividad, 
					d.SubActividad, 
					d.EstadoValidacion, 
					d.Area, 
					d.Comentarios, 
					d.Anexo4, 
					d.Identificador, 
					d.LineaPresupuesto, 
					d.Presupuesto, 
					d.Rubro, 
					d.CatManoObra,
					d.PCN, 
					d.CAA, 
					d.CCN, 
					d.ModificadoPor
				FROM		#Datos	d

		
     END;


