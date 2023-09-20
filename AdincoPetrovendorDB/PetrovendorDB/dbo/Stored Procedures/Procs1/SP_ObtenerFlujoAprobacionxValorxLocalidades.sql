USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ObtenerFlujoAprobacionxValorxLocalidades'
)
    DROP PROCEDURE SP_ObtenerFlujoAprobacionxValorxLocalidades;
/****** Object:  StoredProcedure [dbo].[SP_ObtenerFlujoAprobacionxValor]    Script Date: 05/09/2023 01:06:04 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 05-09-2023
-- Description:	Obtener el id del flujo del pedido x total y proveedor ordenado del valor mas cercano al total 
-- siempre se agrega el predeterminado en caso de no caer en ningun caso caeria por default en predeterminado
-- Copia del sp SP_ObtenerFlujoAprobacionxValor adapatado para preferencia FlujoProcuraConLocalidades
-- =============================================

CREATE PROCEDURE [dbo].[SP_ObtenerFlujoAprobacionxValorxLocalidades] 
@Total FLOAT, 
@IdProveedorCompras INT,
@IdSolicitudPedido INT,
@IdContrato INT
AS
	BEGIN

		DECLARE @tablaAux TABLE
			( 
			  IdFlujoTarea INT ,
			  ValorInicial FLOAT ,
			  ValorFinal FLOAT ,
			  Predeterminado INT ,
			  Nombre NVARCHAR(MAX) ,
			  Orden FLOAT )

		DECLARE @tablaAuxLocalidades TABLE
			(Nombre NVARCHAR(MAX))

		DECLARE @NombreLocalidad NVARCHAR(500)
		DECLARE @IdLocalidad NVARCHAR(500)

		SELECT @NombreLocalidad = LC.Nombre,
		@IdLocalidad = SP.IdLocalidad
		FROM MM_SolicitudPedido SP 
		JOIN MM_Localidades LC 
			ON SP.IdLocalidad = LC.Id
		WHERE IdSolicitudPedido = @IdSolicitudPedido

		--  VALIDAR SI LA SOLICITUD TIENE LOCALIDAD, SI NO TIENE ES HISTORICO Y SE PROCESARA CON EL FLUJO ACTIVO DEFAULT
		IF ISNULL(@IdLocalidad,0)>0
		BEGIN 

			INSERT INTO @tablaAux
				( IdFlujoTarea, ValorInicial, ValorFinal, Predeterminado, Nombre, Orden )

			SELECT		FT.IdFlujoTarea, FTC.ValorInicial, FTC.ValorFinal, ISNULL ( FT.Predeterminado, 0 ), FT.Nombre ,
						CASE WHEN ABS ( FTC.ValorInicial - @Total ) < ABS ( @Total - FTC.ValorFinal ) THEN
								 ABS ( FTC.ValorInicial - @Total )
						ELSE
							ABS ( @Total - FTC.ValorFinal )
						END
			FROM		TA_FlujoTarea AS FT 
			 JOIN	TA_FlujoTareaCondicion AS FTC  
				ON FT.IdFlujoTarea = FTC.IdFlujoTarea 			
			WHERE
						FT.IdProveedor = @IdProveedorCompras					
						AND ISNULL(FT.Eliminado,0) = 0
						AND FT.Activo = 1
						AND @Total BETWEEN FTC.ValorInicial
								   AND	   FTC.ValorFinal					
						AND RTRIM(LTRIM(UPPER(ISNULL(FT.Nombre,'')))) = RTRIM(LTRIM(UPPER(ISNULL(@NombreLocalidad,''))))


			SELECT	ROW_NUMBER () OVER ( ORDER BY Orden ) AS Fila, IdFlujoTarea, ValorInicial, ValorFinal, Predeterminado ,
					Nombre , Orden
			FROM	@tablaAux

		END 
		ELSE 
		BEGIN 
			
			/*OBTENER LOCALIDADES DEL PROVEEDOR ACTUAL, PARA EVITAR TOMAR EL FLUJO DE UNA LOCALIDAD*/
			INSERT INTO @tablaAuxLocalidades(Nombre)
			SELECT RTRIM(LTRIM(UPPER(ISNULL(Nombre,'')))) 
			FROM MM_Localidades
			WHERE IdProveedor = @IdProveedorCompras
			AND Activo =1 
			GROUP BY Nombre 

			
			-- OBTENER LOS FLUJOS DE ACUERDO AL MONTO 		
			
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
				ON FT.IdFlujoTarea = FTC.IdFlujoTarea
			WHERE
						FT.IdProveedor = @IdProveedorCompras
						AND
							ISNULL(	FT.Eliminado,0)=0
						AND FT.ACTIVO = 1
						AND @Total BETWEEN FTC.ValorInicial
								   AND	   FTC.ValorFinal
						OR	(FT.Predeterminado = 1
							AND FT.IdProveedor = @IdProveedorCompras )
			
			-- ELIMINAR TODOS LOS FLUJOS QUE ESTEN RELACIONADOS A UNA LOCALIDAD
			DELETE TF
			FROM @tablaAux TF
			JOIN @tablaAuxLocalidades TL
				ON  RTRIM(LTRIM(UPPER(ISNULL(TF.Nombre,'')))) = RTRIM(LTRIM(UPPER(ISNULL(TL.Nombre,''))))

			-- RETORNAR SOLO EL FLUJO INDICADO
			SELECT	ROW_NUMBER () OVER ( ORDER BY Orden ) AS Fila, IdFlujoTarea, ValorInicial, ValorFinal, Predeterminado ,
					Nombre , Orden
			FROM	@tablaAux			

		END 
	END