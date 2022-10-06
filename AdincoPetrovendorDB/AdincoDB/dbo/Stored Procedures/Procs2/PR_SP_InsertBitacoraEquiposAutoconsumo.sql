USE ADINCO;
GO

CREATE PROCEDURE PR_SP_InsertBitacoraEquiposAutoconsumo
@pIdContrato	int,
@pIdEquipo INT,
@UsuarioId	int,
@Accion VARCHAR(250)
AS
BEGIN
INSERT INTO PR_EquiposAutoconsumoBitacora(
				Accion,CreadoPor,CreadoEl,IdContrato,IdEquipo,Fecha,UTMX,UTMY,Producto,TipoEquipo,
				TAG,FluidoDesplazado,ConsumoTeorico,ConsumoReal,ConsumoEnergetico,DispositivoInyeccion,Obervaciones,Activo
		)SELECT @Accion,@UsuarioId,GETDATE(),IdContrato,IdEquipo,Fecha,UTMX,UTMY,Producto,TipoEquipo,
				TAG,FluidoDesplazado,ConsumoTeorico,ConsumoReal,ConsumoEnergetico,DispositivoInyeccion,Obervaciones,Activo
			FROM [PR_EquiposAutoconsumo] 
			WHERE  
				IdContrato = @pIdContrato
			AND
				IdEquipo = @pIdEquipo;
END
