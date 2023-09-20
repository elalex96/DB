use Petrovendor
go
drop proc if exists MM_ConsultarPreferenciaContrato
go
CREATE PROCEDURE [dbo].[MM_ConsultarPreferenciaContrato] 
@IdProveedor INT ,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN	
		SELECT PC.Id, P.Nombre, PC.ContratoId, PreferenciaId, PC.Valor, PC.Activo 
		FROM AP_Preferencias P (NOLOCK)
		JOIN AP_PreferenciaContrato PC (NOLOCK)
			ON P.Id = PC.PreferenciaId
		WHERE PC.ContratoId = @IdContrato
		AND PC.Activo = 1
		AND P.Activo = 1
END
