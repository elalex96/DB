-- =============================================
-- Author:	Pedro Acu�a
-- Create date: 09-07-2018
-- Description:	obtener el id del flujo del pedido x total y proveedor ordenado del valor mas cercano al total 
-- siempre se agrega el predeterminado en caso de no caer en ningun caso caeria por default en predeterminado
-- =============================================

CREATE PROCEDURE SP_ObtenerFlujoAprobacionxValor @Total FLOAT, @IdProveedorCompras INT
AS
	BEGIN
		DECLARE @tablaAux TABLE
			( IdFlujoTarea INT ,
			  ValorInicial FLOAT ,
			  ValorFinal FLOAT ,
			  Predeterminado INT ,
			  Nombre NVARCHAR(MAX) ,
			  Orden FLOAT )

		INSERT INTO @tablaAux
			( IdFlujoTarea, ValorInicial, ValorFinal, Predeterminado, Nombre, Orden )
		SELECT		FT.IdFlujoTarea, FTC.ValorInicial, FTC.ValorFinal, ISNULL ( FT.Predeterminado, 0 ), FT.Nombre ,
					CASE WHEN ABS ( FTC.ValorInicial - @Total ) < ABS ( @Total - FTC.ValorFinal ) THEN
							 ABS ( FTC.ValorInicial - @Total )
					ELSE
						ABS ( @Total - FTC.ValorFinal )
					END
		FROM		TA_FlujoTarea AS FT
		INNER JOIN	TA_FlujoTareaCondicion AS FTC
			ON FTC.IdFlujoTarea = FT.IdFlujoTarea
		WHERE
					FT.IdProveedor = @IdProveedorCompras
					AND
						(	FT.Eliminado IS NULL
							OR		FT.Eliminado = 0 )
					AND FT.ACTIVO = 1
					AND @Total BETWEEN FTC.ValorInicial
							   AND	   FTC.ValorFinal
					OR	(	FT.Predeterminado = 1
							AND FT.IdProveedor = @IdProveedorCompras )


		SELECT	ROW_NUMBER () OVER ( ORDER BY Orden ) AS Fila, IdFlujoTarea, ValorInicial, ValorFinal, Predeterminado ,
				Nombre , Orden
		FROM	@tablaAux
	END