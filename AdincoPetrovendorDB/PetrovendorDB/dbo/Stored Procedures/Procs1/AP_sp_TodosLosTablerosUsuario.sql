CREATE PROCEDURE AP_sp_TodosLosTablerosUsuario
@IdContrato INT
AS
BEGIN
	SELECT	TU.Id,
			TU.Activo,
			U.Nombre,
			T.NombreMostrar,
			T.Workbook,
			T.Sheet,
			T.DNS,
			T.CreadoEn,
			T.HeightPX,
			T.UserTableau,
			T.MuestraToolBar
			FROM 
		AP_TablerosUsuario as TU
		Join AP_Tableros as T on TU.IdTablero = T.Id
		Join Adinco..AP_Usuario as U on TU.IdUsuario = U.UsuarioID
		where 
			T.IdContrato = @IdContrato
			and TU.Activo = 1 
			AND T.Activo = 1
		order by U.Nombre asc
END