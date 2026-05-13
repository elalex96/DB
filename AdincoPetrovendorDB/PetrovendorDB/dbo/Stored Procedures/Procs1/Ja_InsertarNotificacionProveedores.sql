-- =============================================
 
-- Modified: DANIEL AC 
-- Updated date: 02/01/2017 
-- Description: Agregue parametro IdProveedor, IdContrato   
-- =============================================
CREATE PROC [dbo].[Ja_InsertarNotificacionProveedores]
(
    @IdSolPed INT,
    @IdUsuario INT,
    @TipoMensaje INT,
    @IdPrimario INT = 0,
    @PetrovendorProcura INT = 2,  --Petrovendor 0 - Procura 1 - Adinco 2
	@IdProveedorCreador INT, 
	@IdContratoCreador INT = NULL 
)
AS
BEGIN
    DECLARE @IdComentario INT,           
            @OfertaMensaje INT,
            @NumeroDeProveedores INT,
            @Contador INT = 1,
            @max INT,       
			@IdProveedor INT 

    --SELECT @IdProveedorCreador = uProv.IdProveedor
    --FROM dbo.S_UsuarioProveedor uProv
    --WHERE uProv.IdUsuario = @IdUsuario

    DECLARE @tablaAux TABLE
    (
        Fila INT,
        IdProveedor INT,
        OfertaMensaje INT
    )

    --insertar en la tabla auxiliar siempre y cuando el proveedor no sea el mismo que esta realizando el mensaje
    INSERT INTO @tablaAux
    (
        Fila,
        IdProveedor,
        OfertaMensaje
    )
    SELECT ROW_NUMBER() OVER (ORDER BY IdPeticionOferta),
           IdProveedor,
           IdPeticionOferta
    FROM dbo.MM_PeticionOferta petOf
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON petOf.IdSubcontratista = uProv.IdProveedor
    WHERE IdSolicitudPedido = @IdSolPed
          AND uProv.IdProveedor != @IdProveedor
    GROUP BY uProv.IdProveedor,petOf.IdPeticionOferta

    --obtener el max para el usuario creador
    SELECT @max = (MAX(Fila) + 1)
    FROM @tablaAux

    --Si el usuario esta registrando en petrovendor
    IF (@PetrovendorProcura = 0)
    BEGIN
        INSERT INTO @tablaAux
        (
            Fila,
            IdProveedor,
            OfertaMensaje
        )
        SELECT TOP 1
            @max,
            sp.IdProveedor,
            petOfert.IdPeticionOferta
        FROM dbo.MM_PeticionOferta petOfert           
			INNER JOIN dbo.MM_SolicitudPedido sp 
				ON sp.IdSolicitudPedido=petOfert.IdSolicitudPedido
        WHERE petOfert.IdSolicitudPedido = @IdSolPed 

    END

    --cuenta de los usuarios que seran notificados
    SELECT @NumeroDeProveedores = COUNT(Fila)
    FROM @tablaAux

    WHILE (@Contador <= @NumeroDeProveedores)
    BEGIN
        SELECT @IdProveedor = IdProveedor,
               @OfertaMensaje = OfertaMensaje
        FROM @tablaAux
        WHERE Fila = @Contador

        --inserto en mensajes pendientes para notificarle al usuario que tiene mensajes pendientes
        INSERT INTO dbo.Ja_MensajesPendientesComentarios
        (
            IdPrimario,
            IdProveedor,
            TipoMensaje,
            Enviado,
            FechaEnviado,
            Visto,
            IdOferta,
            IdSolPed,
			IdProveedorCreador,
			FechaCreado,
			IdContratoCreador
        )
        VALUES
        (   @IdPrimario,  -- IdPrimario - int
            @IdProveedor,   -- IdProveedor - int
            @TipoMensaje,   -- TipoMensaje - int 4 es el tipo de encabezado
            0,              -- Enviado - bit
            GETDATE(),      -- FechaEnviado - datetime
            0,              -- Visto - bit
            @OfertaMensaje, -- IdOferta - int
            @IdSolPed,       -- IdSolPed - int
			@IdProveedorCreador,
			GETDATE(),
			@IdContratoCreador
        )
        SET @Contador += 1
    END

END