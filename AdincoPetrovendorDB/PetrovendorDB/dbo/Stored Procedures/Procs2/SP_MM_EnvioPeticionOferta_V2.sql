USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_EnvioPeticionOferta_V2'
)
    DROP PROCEDURE SP_MM_EnvioPeticionOferta_V2;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/02/2020>
-- Description:	<Envio de la peticion oferta>
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/02/2021>
-- Description:	<eliminado del campo de prioridad y tipo gasto>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_EnvioPeticionOferta_V2]
-- Add the parameters for the stored procedure here@IdPrioridad
@ProveedorInvitados NVARCHAR(MAX),
@IdSolicitudPedido INT,
@CreadoPor INT,
@IdProveedorActual INT,
@Descripcion NVARCHAR(MAX),
@FechaLimiteCotizacion DATETIME,
@IdTerminosCondiciones INT,
@Justificacion NVARCHAR(MAX),
@CorreosInvitados NVARCHAR(MAX),
@CotizacionRestringida BIT = NULL,
@DocumentosMinimos dbo.DocsRequerimientosMinimos READONLY
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	SELECT @IdProveedorActual = IdProveedor
        FROM dbo.MM_SolicitudPedido
        WHERE IdSolicitudPedido = @IdSolicitudPedido

    DECLARE @IDPROVEEDORINV INT;
    DECLARE @CONTPROVEDORES INT;
    DECLARE @IDPETICIONOFERTA INT;
    DECLARE @CONTAD INT = 1;
    DECLARE @CONTTOTALADMIN INT;
    DECLARE @IdNotificacion BIGINT;
    DECLARE @CONT INT = 1;
    DECLARE @CONTCORREOSINVITADOS INT = 1;
    DECLARE @TOTALCORREOSINVITADOS INT;
    DECLARE @CORREOINVITACIONC NVARCHAR(100);
    DECLARE @HTMLPROVEEDORESINV NVARCHAR(MAX);
    DECLARE @CODIGOACTIVACIONC NVARCHAR(6);
    DECLARE @CORREOADMIN VARCHAR(MAX);
    DECLARE @HTMLCORREOSINV NVARCHAR(MAX);
    DECLARE @ASUNTOPROVEEDORESINV NVARCHAR(MAX);
    DECLARE @ASUNTOCORREOSINV NVARCHAR(MAX);
    DECLARE @NOMBREPROVEEDORACTUAL NVARCHAR(100);

    CREATE TABLE #PROVEEDORESINVITADOS (IdRow INT IDENTITY(1, 1) PRIMARY KEY, IdProveedorInvitado INT);

    CREATE TABLE #CORREOSADMINS
    (
        IdRow INT IDENTITY(1, 1) PRIMARY KEY,
        Correo NVARCHAR(100),
        Nombre NVARCHAR(100),
        IdUsuario INT
    );

    CREATE TABLE #CORREOSINVITADOS (IdRow INT IDENTITY(1, 1) PRIMARY KEY, CorreoInvitado NVARCHAR(100));

	SET @NOMBREPROVEEDORACTUAL =
            (   SELECT RazonSocial
                FROM dbo.S_Proveedor (NOLOCK)
                WHERE IdProveedor = @IdProveedorActual);

    INSERT INTO #CORREOSINVITADOS
    SELECT Datos
    FROM dbo.SplitString(@CorreosInvitados, ',');

    SET @TOTALCORREOSINVITADOS = (SELECT COUNT(IdRow) FROM #CORREOSINVITADOS);

    WHILE @CONTCORREOSINVITADOS <= @TOTALCORREOSINVITADOS
    BEGIN
        SET @CORREOINVITACIONC =
        (   SELECT CorreoInvitado
            FROM #CORREOSINVITADOS
            WHERE IdRow = @CONTCORREOSINVITADOS);
        SET @CODIGOACTIVACIONC = (SUBSTRING(CONVERT(VARCHAR(255), NEWID()), 0, 7));
        SET @HTMLCORREOSINV = (SELECT HTML FROM dbo.TA_Correo (NOLOCK) WHERE IdCorreo = 18);

        SET @HTMLCORREOSINV
            = (REPLACE(@HTMLCORREOSINV, '##NombreEmpresa##', @NOMBREPROVEEDORACTUAL));
        SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV, '##NO_CODIGO##', @CODIGOACTIVACIONC));
        SET @HTMLCORREOSINV
            = (REPLACE(@HTMLCORREOSINV, '##CORREO_INVITACION##', @CORREOINVITACIONC));
        SET @HTMLCORREOSINV = (REPLACE(@HTMLCORREOSINV, '##ANIO_ACTUAL##', YEAR(GETDATE())));
        SET @HTMLCORREOSINV
            = (REPLACE(@HTMLCORREOSINV, '##DOMINIO##', 'https://petrovendor.com.mx/'));
        SET @HTMLCORREOSINV
            = (REPLACE(
               @HTMLCORREOSINV, '##SOLICITUD_PEDIDO##', CAST(@IdSolicitudPedido AS NVARCHAR(100))));

        SET @IdNotificacion = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion (NOLOCK)) + 1);

        INSERT INTO Adinco.dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De
        )
        VALUES
        (@IdNotificacion, @CORREOINVITACIONC, 'Invitación Cotización Petrovendor ',
         @HTMLCORREOSINV, DATEADD(MINUTE, 1, GETDATE()), 0, NULL, 3, GETDATE(), NULL, NULL,
         'procura@adinco.mx');

        INSERT INTO dbo.TA_EnvioCorreo (IdEnvioAdinco, IdCorreo, IdIdentificacion, EnviadoPor, EnviadoEl)
        VALUES
        (   @IdNotificacion,                                                          -- IdEnvioAdinco - int
            18,                                                                       -- CORREO DE PETICION OFERTA
            CONCAT('0 - Codigo de Invitacion Peticion oferta #', @IdSolicitudPedido), -- IdIdentificacion - int
            @CreadoPor, GETDATE());


        --BITACORA DE CORREO
        INSERT INTO dbo.TA_BitacoraCorreo
        (
            IdDocumento,
            Detalle,
            Correo,
            Enviado,
            FechaEnvio,
            IdUsuarioEnvio,
            IdProveedorEnvio,
            IdUsuarioReceptor
        )
        VALUES
        (   @IdSolicitudPedido,                           -- IdDocumento - int
            N'Notificacion Petición Oferta/Recuperación', -- Detalle - nvarchar(max)
            @CORREOINVITACIONC,                           -- Correo - nvarchar(350)
            1,                                            -- Enviado - bit
            GETDATE(),                                    -- FechaEnvio - datetime
            0,                                            -- IdUsuarioEnvio - int
            0,                                            -- IdProveedorEnvio - int
            0                                             -- IdUsuarioReceptor - int
        );

        --

        INSERT INTO MM_InvitacionPeticionOferta
        (
            [Fecha],
            [CorreoEnviado],
            [IdSolicitudPedido],
            [CreadoPor],
            [CorreoInvitacion],
            [Invitado],
            [Activo],
            [IdProveedorInvito],
            CodigoActivacion,
            InvitacionPorCorreo,
            [CotizacionRestringida]
        )
        VALUES
        (GETDATE(), 1, @IdSolicitudPedido, @CreadoPor, @CORREOINVITACIONC, 1, 1,
         @IdProveedorActual, @CODIGOACTIVACIONC, 1, @CotizacionRestringida);

        SET @CONTCORREOSINVITADOS = @CONTCORREOSINVITADOS + 1;
    END

    INSERT INTO #PROVEEDORESINVITADOS
    SELECT CAST(Datos AS INT)
    FROM dbo.SplitString(@ProveedorInvitados, ',');

    SET @CONTPROVEDORES = (SELECT COUNT(IdRow) FROM #PROVEEDORESINVITADOS);

    --ENVIO DE LA PETICIONES OFERTAS A LOS PROVEEDORES
    WHILE @CONT <= @CONTPROVEDORES
    BEGIN

        --SE OBTIENE EL PROVEEDOR DE LA PETICION DE LA TABLA RECIVIDA
        SET @IDPROVEEDORINV = (SELECT IdProveedorInvitado FROM #PROVEEDORESINVITADOS WHERE IdRow = @CONT);

        --CABECERA DE LA PETICION OFERTA
        INSERT INTO dbo.MM_PeticionOferta
        (
            IdSolicitudPedido,
            IdSubcontratista,
            CreadoPor,
            CreadoEl,
            Activo,
            Visto,
            Iniciada,
            IdTipoProceso,
            CotizacionRestringida
        )
        VALUES
        (   @IdSolicitudPedido, @IDPROVEEDORINV, @CreadoPor, GETDATE(), 1, 1, 0, 2, --MERCADEO
            @CotizacionRestringida);

        SET @IDPETICIONOFERTA = (SCOPE_IDENTITY());

        --AGREDADO DE LOS DETALLES DE LA PETICION OFERTA
        --VALIDACION DE COTIZACION RESTRINGIDA
        IF ISNULL(@CotizacionRestringida, 0) > 0
        BEGIN
            INSERT INTO MM_PeticionOfertaDetalle
            (
                IdPeticionOferta,
                IdSolicitudPedidoDetalle,
                IdMaterial,
                IdMaterialVendedor,
                ComentariosComprador,
                CreadoEl,
                CreadoPor,
                Activo,
                NoMaterialesRequeridos,
                IdProveedorVenta,
                Cotizado,
                IdUnidad,
                IdUnidadProveedor
            )
            SELECT @IDPETICIONOFERTA,
                   IdSolicitudPedidoDetalle,
                   IdMaterial,
                   IdMaterial,
                   observaciones,
                   GETDATE(),
                   @CreadoPor,
                   1,
                   Cantidad,
                   @IDPROVEEDORINV,
                   0,
                   IdUnidad,
                   IdUnidad
            FROM dbo.MM_SolicitudPedidoDetalle (NOLOCK)
            WHERE IdSolicitudPedido = @IdSolicitudPedido;
        END
        ELSE
        BEGIN
            INSERT INTO MM_PeticionOfertaDetalle
            (
                IdPeticionOferta,
                IdSolicitudPedidoDetalle,
                IdMaterial,
                ComentariosComprador,
                CreadoEl,
                CreadoPor,
                Activo,
                NoMaterialesRequeridos,
                IdProveedorVenta,
                Cotizado,
                IdUnidad
            )
            SELECT @IDPETICIONOFERTA,
                   IdSolicitudPedidoDetalle,
                   IdMaterial,
                   observaciones,
                   GETDATE(),
                   @CreadoPor,
                   1,
                   Cantidad,
                   @IDPROVEEDORINV,
                   0,
                   IdUnidad
            FROM dbo.MM_SolicitudPedidoDetalle (NOLOCK)
            WHERE IdSolicitudPedido = @IdSolicitudPedido;
        END



        --ENVIO DE CORREOS A LOS ADMINISTRADORES
        INSERT INTO #CORREOSADMINS
        SELECT U.Correo,
               U.Nombre,
               U.IdUsuario
        FROM S_Usuario AS U (NOLOCK)
            INNER JOIN S_UsuarioProveedor AS UP (NOLOCK)
                ON U.IdUsuario = UP.IdUsuario
            INNER JOIN S_Proveedor AS P (NOLOCK)
                ON UP.IdProveedor = P.IdProveedor
        WHERE P.IdProveedor = @IDPROVEEDORINV
              AND (U.IdTipoUsuario = 4 OR U.IdTipoUsuario = 3)
              AND U.Activo = 1;

        SET @CONTTOTALADMIN = (SELECT COUNT(IdRow) FROM #CORREOSADMINS);

        WHILE @CONTAD <= @CONTTOTALADMIN
        BEGIN

            SET @IdNotificacion
                = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion (NOLOCK)) + 1);
            SET @CORREOADMIN = (SELECT Correo FROM #CORREOSADMINS WHERE IdRow = @CONTAD);
            SET @HTMLPROVEEDORESINV = (SELECT HTML FROM dbo.TA_Correo (NOLOCK) WHERE IdCorreo = 11);
            --SET @ASUNTOPROVEEDORESINV = (SELECT Asunto FROM dbo.TA_Correo WHERE IdCorreo = 11);
            --ARMADO DEL HTML
            --ASUNTO
            --SET @ASUNTOPROVEEDORESINV = (REPLACE(@ASUNTOPROVEEDORESINV,'##NO##',CAST(@IDPETICIONOFERTA AS NVARCHAR(100))));
            --NOMBRE USUARIO
            SET @HTMLPROVEEDORESINV
                = (REPLACE(
                   @HTMLPROVEEDORESINV,
                   '##NOMBRE_USUARIO##',
                   (SELECT Nombre FROM #CORREOSADMINS WHERE IdRow = @CONTAD)));
            --DESCRIPCION
            SET @HTMLPROVEEDORESINV
                = (REPLACE(@HTMLPROVEEDORESINV, '##DESCRIPCION_TAREA##', @Descripcion));
            --URL
            SET @HTMLPROVEEDORESINV
                = (REPLACE(
                   @HTMLPROVEEDORESINV,
                   '##URL_PO##',
                   CONCAT(
                   'https://petrovendor.com.mx/01Proveedores/CO_CotizacionDetalle.aspx?oferta=',
                   CAST(@IDPETICIONOFERTA AS NVARCHAR(100)))));
            --AÑO
            SET @HTMLPROVEEDORESINV
                = (REPLACE(
                   @HTMLPROVEEDORESINV, '##ANIO_ACTUAL##', CAST(YEAR(GETDATE()) AS NVARCHAR(100))));
            --SOLICITUD DE PEDIDO
            SET @HTMLPROVEEDORESINV
                = (REPLACE(
                   @HTMLPROVEEDORESINV,
                   '##SOLICITUD_PEDIDO##',
                   CAST(@IdSolicitudPedido AS NVARCHAR(100))));
            --CORREO


            INSERT INTO Adinco.dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De
            )
            VALUES
            (@IdNotificacion, @CORREOADMIN,
             CONCAT('Petición Oferta No.', ISNULL(@IDPETICIONOFERTA, 0)), @HTMLPROVEEDORESINV,
             DATEADD(MINUTE, 1, GETDATE()), 0, NULL, 3, GETDATE(), NULL, NULL, 'procura@adinco.mx');

            INSERT INTO dbo.TA_EnvioCorreo (IdEnvioAdinco, IdCorreo, IdIdentificacion, EnviadoPor, EnviadoEl)
            VALUES
            (   @IdNotificacion,                                     -- IdEnvioAdinco - int
                11,                                                  -- CORREO DE PETICION OFERTA
                CONCAT('0 - Nueva cotización #', @IDPETICIONOFERTA), -- IdIdentificacion - int
                @CreadoPor, GETDATE());


            --BITACORA DE CORREO
            INSERT INTO dbo.TA_BitacoraCorreo
            (
                IdDocumento,
                Detalle,
                Correo,
                Enviado,
                FechaEnvio,
                IdUsuarioEnvio,
                IdProveedorEnvio,
                IdUsuarioReceptor
            )
            VALUES
            (   @IDPETICIONOFERTA,                            -- IdDocumento - int
                N'Notificacion Petición Oferta/Recuperación', -- Detalle - nvarchar(max)
                @CORREOADMIN,                                 -- Correo - nvarchar(350)
                1,                                            -- Enviado - bit
                GETDATE(),                                    -- FechaEnvio - datetime
                0,                                            -- IdUsuarioEnvio - int
                0,                                            -- IdProveedorEnvio - int
                0                                             -- IdUsuarioReceptor - int
            );

            --

            INSERT INTO MM_InvitacionPeticionOferta
            (
                [Fecha],
                [CorreoEnviado],
                [IdSolicitudPedido],
                [IdProveedorInvitado],
                [CreadoPor],
                [IdPeticionOferta],
                [CorreoInvitacion],
                [Invitado],
                [Activo],
                [IdProveedorInvito],
                [CotizacionRestringida]
            )
            VALUES
            (GETDATE(), 1, @IdSolicitudPedido, @IDPROVEEDORINV, @CreadoPor, @IDPETICIONOFERTA,
             @CORREOADMIN, 1, 1, @IdProveedorActual, @CotizacionRestringida)

            SET @CONTAD = @CONTAD + 1;

        END;

        SET @CONTAD = 1; --SE FORMATEA EL CONTADOR
        SET @CONTTOTALADMIN = 0;
        TRUNCATE TABLE #CORREOSADMINS; --SE VACIA LA TABLA PARA LOS ADMINISTRADORES DEL SIG PROVEEDOR

        SET @CONT = @CONT + 1;
    END;

    --ACTUALIZAR EL TIPO DE PROCESO EN LA SOLICITUD DE PEDIDO
    UPDATE dbo.MM_SolicitudPedido
    SET IdTipoProceso = 2 --MERCADEO
    WHERE IdSolicitudPedido = @IdSolicitudPedido

    --Agregar Operación -- > Espera cambio de estatus cuando los proveedores terminen su cotización Operacion Tipo Peticion Oferta
    DECLARE @DescripcionH NVARCHAR(MAX)
    DECLARE @IdOperacion INT;
    DECLARE @IdFlujoTarea INT;

    SET @IdOperacion =
    (   SELECT TOP 1
               IdOperacion
        FROM dbo.TA_Operacion (NOLOCK)
        WHERE IdDocumento = @IdSolicitudPedido
              AND IdTipoOperacion = 6
              AND IdEstatusOperacion = 1
              AND IdProveedor = @IdProveedorActual
              AND IdAsignador = @CreadoPor
			  );

    IF ISNULL(@IdOperacion, 0) = 0
    BEGIN
        
        INSERT INTO dbo.TA_Operacion
        (
            IdDocumento,
            IdTipoOperacion,
            IdEstatusOperacion,
            IdProveedor,
            IdAsignador,
            FechaRegistro,
            Descripcion,
            IdVigencia,
            IdPrioridad
        )
        VALUES
        (@IdSolicitudPedido, 6, 1, @IdProveedorActual, @CreadoPor, GETDATE(), @Descripcion,
         1, 1
		 );

        SET @IdOperacion = (SCOPE_IDENTITY())

    END

    --ACTUALIZAR LA FECHA LIMITE A COTIZAR
    UPDATE TA_Operacion
    SET FechaFinalizacion = @FechaLimiteCotizacion
    WHERE IdOperacion = @IdOperacion;

    --ACTUALIZAR ENVIO DE LA PETICION
    UPDATE [dbo].[MM_SolicitudPedido]
    SET [PeticionEnviada] = 1,
        JustificacionSolOferta = @Justificacion
        --IdTipoGasto = @IdTipoGasto
    WHERE [IdSolicitudPedido] = @IdSolicitudPedido

    --GUARDAR LOS TERMINOS Y CONDICIONES
    INSERT INTO dbo.TA_TerminosCondicionesOperacion (IdOperacion, IdTerminosYCondiciones, TerminosCondicionesTexto)
    VALUES
    (   @IdOperacion,           -- IdOperacion - int
        @IdTerminosCondiciones, -- IdTerminosYCondiciones - int
        (   SELECT TOP 1
                   Documento
            FROM dbo.TC_TerminosYCondicionesDocV2
            WHERE IdTerminosYCondiciones = @IdTerminosCondiciones));

    INSERT INTO dbo.RN_DocumentosMinimosProveedor
    SELECT @IdSolicitudPedido,
           D.IdTipoRegimen,
           D.IdTipoDocumento
    FROM @DocumentosMinimos AS D;

    SELECT @IdOperacion AS IdOperacion

END