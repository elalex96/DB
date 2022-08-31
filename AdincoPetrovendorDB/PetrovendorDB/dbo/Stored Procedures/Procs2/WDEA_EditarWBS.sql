USE Petrovendor
GO
DROP PROCEDURE IF EXISTS WDEA_EditarWBS
GO
CREATE PROCEDURE WDEA_EditarWBS
@WBS varchar(300),
@IdContrato int,
@IdUsuario int,
@Id int
AS
BEGIN
	Update WDEA_WBS
	set ModificadoEl = GETDATE(),
	ModificadoPor = @IdUsuario,
	WBS = @WBS
	where Id = @Id
END
