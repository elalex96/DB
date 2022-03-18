USE Adinco;
GO
CREATE PROCEDURE [dbo].[RPT_CertificadoElegibles]
@MesPresentacion datetime,     
@PresupuestoId     INT
AS    
BEGIN
		DECLARE @TotalAprobado Decimal(18, 2), @Presupuesto nvarchar(500)
        CREATE TABLE #TotalAprobados(Total Decimal(18, 2),Mes varchar(100) , USD Decimal (18, 4))

		 INSERT INTO #TotalAprobados(Total,Mes)
		 exec SP_CO_InformeRevGast_TotalAprobados @PresupuestoId, @MesPresentacion 

		 SELECT @Presupuesto = Nombre FROM CO_Presupuesto where IdPresupuesto = @PresupuestoId
		 SELECT @TotalAprobado = Total FROM #TotalAprobados

		 SELECT @Presupuesto as NombrePeriodo, @MesPresentacion as PeriodoRevisado, ISNULL(@TotalAprobado, 0) as TotalGastosElegibles
END

