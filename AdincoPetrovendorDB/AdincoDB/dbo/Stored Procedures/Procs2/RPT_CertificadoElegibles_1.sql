CREATE PROCEDURE [dbo].[RPT_CertificadoElegibles] 
@MesPresentacion datetime,     
@PresupuestoId     INT
AS    
BEGIN
		DECLARE @TotalAprobado Decimal(18, 2), @Presupuesto nvarchar(500)
        CREATE TABLE 
			#TotalAprobados
		(
			Total Decimal(18, 2),
			Mes varchar(150),
			MesRevGastosElegibles varchar(150),
			MesGastosPendientesReconocer varchar(150),
			MesInformeContableGastos varchar(200),
			Presupuesto varchar(150),
			USD Decimal (18, 4)
		)

		 INSERT INTO #TotalAprobados(Total, Mes, MesRevGastosElegibles, MesGastosPendientesReconocer, MesInformeContableGastos, Presupuesto)
		 exec SP_CO_InformeRevGast_TotalAprobados @PresupuestoId, @MesPresentacion 

		 SELECT @Presupuesto = Nombre FROM CO_Presupuesto where IdPresupuesto = @PresupuestoId
		 SELECT @TotalAprobado = Total FROM #TotalAprobados
		
		 SELECT @Presupuesto as NombrePeriodo, ISNULL(@MesPresentacion, '') as PeriodoRevisado, ISNULL(@TotalAprobado, 0) as TotalGastosElegibles		 
END

