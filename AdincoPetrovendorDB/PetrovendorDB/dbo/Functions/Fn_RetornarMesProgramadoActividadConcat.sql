-- =============================================
-- Author: Pedro Acuña
-- Create date: 07/11/2018
-- Description: retornar el mes programado, la actividad, subactividad, tarea, clave tarea y a subtarea
-- =============================================

CREATE FUNCTION Fn_RetornarMesProgramadoActividadConcat
	( @IdLineaPresupuestoMes INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)

		SELECT		@retorno
			= CONCAT (
				  'Mes Programado: ' , RIGHT('00' + LTRIM ( MONTH ( lpm.AC_PRESUP_MES )), 2), ' ' ,
				  dbo.Fn_RetornarMesEspanol ( MONTH ( lpm.AC_PRESUP_MES )), ' ', YEAR ( lpm.AC_PRESUP_MES ) ,
				  ' | Actividad: ' , CASE WHEN CO.IdTipoContrato = 1 THEN
											 ts.NombreTipoServicio
									ELSE
										apCNH.DescripcionActividadPetrolera
									END COLLATE Modern_Spanish_CI_AS ,				-- Actividad
				  ' | Sub-Actividad: ', CASE WHEN CO.IdTipoContrato = 1 THEN
												 aCIEP.NombreActividad
										ELSE
											SAP.SubactividadPetrolera
										END COLLATE Modern_Spanish_CI_AS ,			-- SubActividad
				  ' | Tarea: ', tp.TareaPetrolera COLLATE Modern_Spanish_CI_AS ,	-- Tarea
				  ' | Clave Tarea: ', tp.id_Tarea COLLATE Modern_Spanish_CI_AS ,	-- Clave Tarea
				  ' | Sub-Tarea: ', s.NombreServicio COLLATE Modern_Spanish_CI_AS ) -- Sub Tarea        
		FROM		Adinco.dbo.CO_LineaPresupuestoMes lpm
		LEFT JOIN	Adinco.dbo.CO_Registro R
			ON LPM.IdLineaPresupuestoMes = R.IdPrograma
		LEFT JOIN	Adinco.dbo.FI_Factura F
			ON R.IdFactura = F.IdFactura
		LEFT JOIN	Adinco.dbo.CO_TipoCambioDiario TCD
			ON F.IdMoneda = TCD.IdMoneda
			   AND	YEAR ( TCD.Fecha ) = YEAR ( F.Fecha )
			   AND	MONTH ( TCD.Fecha ) = MONTH ( F.Fecha )
			   AND	DAY ( TCD.Fecha ) = DAY ( F.Fecha )
		LEFT JOIN	Adinco.dbo.CO_Presupuesto P
			ON P.IdPresupuesto = LPM.IdPresupuesto
		LEFT JOIN	Adinco.dbo.CO_AnioContractual AC
			ON AC.IdAnioContractual = P.IdAnioContractual
		LEFT JOIN	Adinco.dbo.CO_Contrato CO
			ON CO.IdContrato = AC.IdContrato
		LEFT JOIN	Adinco.dbo.CO_ActividadPetroleraCNH APCNH
			ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
		LEFT JOIN	Adinco.dbo.CO_SubactividadPetrolera SAP
			ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
		LEFT JOIN	Adinco.dbo.CO_TareaPetrolera TP
			ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
		LEFT JOIN	Adinco.dbo.CO_ActividadCIEP AS ACIEP
			ON LPM.IdActividad = ACIEP.IdActividad
		LEFT JOIN	Adinco.dbo.CO_TipoServicio TS
			ON LPM.IdTipoServicio = TS.ID_TIPOSER
		LEFT JOIN	Adinco.dbo.CO_Servicio S
			ON LPM.IdServicio = S.IdServicio
		LEFT JOIN	Adinco.dbo.CO_Instalacion I
			ON LPM.IdInstalacion = I.IdInstalacion
		WHERE		lpm.IdLineaPresupuestoMes = @IdLineaPresupuestoMes

		RETURN @retorno
	END