CREATE PROC SP_EN_ActualizaConjuncionPalabra
@Id int,
@Palabra varchar(500),
@Sustitucion varchar(200),
@IdUsuario int,
@Activo bit
AS
BEGIN
		UPDATE EN_ConjuncionesDocumentos
		set 
		Palabra = CONCAT(' ',@Palabra,' '),
		Activo = @Activo,
		Sustitucion = isnull(@Sustitucion,''),
		ModificacdoPor = @IdUsuario,
		ModificadoEl = GETDATE()
		where 
		Id = @Id
END