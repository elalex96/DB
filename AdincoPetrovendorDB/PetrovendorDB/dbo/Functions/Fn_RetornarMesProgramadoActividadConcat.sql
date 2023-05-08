-- =============================================
-- Author: Pedro Acuña
-- Create date: 07/11/2018
-- Description: retornar el mes programado, la actividad, subactividad, tarea, clave tarea y a subtarea
-- =============================================
-- Author: Luis David
-- Create date: 09/02/2023
-- Description: Se retorna la clave de la actibidad y Subactividad
-- =============================================
CREATE FUNCTION [dbo].[Fn_RetornarMesProgramadoActividadConcat]
	( @IdLineaPresupuestoMes INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)

		SELECT		@retorno
			= CONCAT (
				  'Mes Programado: ' , RIGHT('00' + LTRIM ( MONTH ( lpm.AC_PRESUP_MES )), 2), ' ' ,
				  dbo.Fn_RetornarMesEspanol ( MONTH ( lpm.AC_PRESUP_MES )), ' ', YEAR ( lpm.AC_PRESUP_MES ) ,
				  ' | ',id_Actividad,
				  ' | Actividad: ' , CASE
									   WHEN P.CIEP = 1
									   THEN ACIEP.NombreActividad
									   ELSE SAP.SubactividadPetrolera
								   END COLLATE Modern_Spanish_CI_AS ,				-- Actividad
				  ' | ',SAP.[id_Sub-actividad],
				  ' | Sub-Actividad: ', CASE
										   WHEN P.CIEP = 1
										   THEN RI.NombreRubro
										   ELSE TP.TareaPetrolera
									   END COLLATE Modern_Spanish_CI_AS ,			-- SubActividad
				  ' | Tarea: ', tp.TareaPetrolera COLLATE Modern_Spanish_CI_AS ,	-- Tarea
				  ' | Clave Tarea: ', tp.id_Tarea COLLATE Modern_Spanish_CI_AS ,	-- Clave Tarea
				  ' | Sub-Tarea: ', s.NombreServicio COLLATE Modern_Spanish_CI_AS ) -- Sub Tarea        
		FROM		Adinco.dbo.CO_LineaPresupuestoMes lpm (NOLOCK)
		JOIN	Adinco.dbo.CO_Presupuesto P (NOLOCK)
			ON P.IdPresupuesto = LPM.IdPresupuesto
		JOIN	Adinco.dbo.CO_AnioContractual AC (NOLOCK)
			ON AC.IdAnioContractual = P.IdAnioContractual
		JOIN	Adinco.dbo.CO_Contrato CO (NOLOCK)
			ON CO.IdContrato = AC.IdContrato
		LEFT JOIN	Adinco.dbo.CO_ActividadPetroleraCNH APCNH (NOLOCK)
			ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
		LEFT JOIN	Adinco.dbo.CO_SubactividadPetrolera SAP (NOLOCK)
			ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
		LEFT JOIN	Adinco.dbo.CO_TareaPetrolera TP (NOLOCK)
			ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
		LEFT JOIN	Adinco.dbo.CO_ActividadCIEP AS ACIEP (NOLOCK)
			ON LPM.IdActividad = ACIEP.IdActividad
		LEFT JOIN	Adinco.dbo.CO_TipoServicio TS (NOLOCK)
			ON LPM.IdTipoServicio = TS.ID_TIPOSER
		LEFT JOIN	Adinco.dbo.CO_Servicio S (NOLOCK)
			ON LPM.IdServicio = S.IdServicio
		LEFT JOIN	Adinco.dbo.CO_Instalacion I (NOLOCK)
			ON LPM.IdInstalacion = I.IdInstalacion
		LEFT JOIN dbo.CO_RubroInterno RI (NOLOCK) 
			ON LPM.IdRubroInterno = RI.IdRubroInterno
		WHERE lpm.IdLineaPresupuestoMes = @IdLineaPresupuestoMes

		RETURN @retorno
	END