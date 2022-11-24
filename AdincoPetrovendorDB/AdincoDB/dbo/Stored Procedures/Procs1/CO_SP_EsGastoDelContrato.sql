--AGREGAR SCRIPT DEL MENÚ
-- 
--SELECT * FROM AP_MenuD
CREATE PROCEDURE [dbo].[CO_SP_EsGastoDelContrato]--10007,2,117940
@IdContrato INT,
@IdUsuario INT,
@IdRegistro INT
AS
     BEGIN
         SET NOCOUNT ON;
         SET LANGUAGE spanish;
		 
		 DECLARE @EsdeContrato INT = 0;
		 
		 SELECT @EsdeContrato =
		 CASE AC.IdContrato 
		 WHEN @IdContrato
			THEN 1
			ELSE 0
		 END
		 FROM 
			CO_Registro	R
		JOIN
			CO_LineaPresupuestoMes LPM
			ON	R.IdPrograma	=	LPM.IdLineaPresupuestoMes
		JOIN
			CO_Presupuesto	P
			ON	LPM.IdPresupuesto	=	P.IdPresupuesto
		JOIN
			CO_AnioContractual	AC	
			ON	P.IdAnioContractual	=	AC.IdAnioContractual
		 WHERE	IdRegistro	=	@IdRegistro;


		 select @EsdeContrato
     END;


