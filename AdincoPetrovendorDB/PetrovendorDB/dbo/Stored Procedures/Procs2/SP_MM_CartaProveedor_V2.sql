-- =============================================  
-- Author:  Manuel Cruz  
-- Create date: 26-06-17  
-- Description:   
-- =============================================  
--Tener en cuenta que no se utiliz aen realidad el IdPedido sino el Id Aceptacion, me imagino que no se corrigio para no tener que mover el nombre y mover codigo del lado del servidor  
-- =============================================  
-- Author:  Pedro Acuña  
-- Create date: 31-07-2018  
-- Description:  se verifica que los usuarios esten activos, ademas de empezar la lista por el administrador para que se muestre su correo,  
-- en caso de estar desactivado pasa al siguiente usuario activo  
-- =============================================  
-- Author:  Pedro Acuña  
-- Create date: 11-03-2019  
-- Description:  se modifica la consulta ya que ahora puede tener mas de un representante legal  
-- =============================================  
-- Author:  Abel Rivera  
-- Create date: 26/ago/2019  
-- Description: se agrego un campo para validar si el proveedor esta en la lista negra  
-- =============================================  
-- Author:  Alexander Gomez  
-- Create date: 26/09/2019  
-- Description: se homologo el resultado de los materiales en PCN a 3 decimales  
-- =============================================  
-- Author:  Alexander Gomez  
-- Create date: 27/09/2019  
-- Description: se modifico el ordern del nombre del representante legal (Nombre, Apellidos)  
-- =============================================  

CREATE PROCEDURE [dbo].[SP_MM_CartaProveedor_V2] --480,2058,0,0,'',46
-- Add the parameters for the stored procedure here  
@IdProveedor INT,
@IdAceptacionPedido INT,
@IdContrato INT,
@IdUsuario INT,
@fchRegistro DATETIME,
@IdsRepresentanteLegal NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- /////////////////////////////////////Seccion cabecera  
    DECLARE @IdTipoRegimen INT;
    DECLARE @NombreOperadora NVARCHAR(MAX);
    --/** Validacion BIenes o servicio **/  
    DECLARE @CantidadTiposXAceptacion INT;

    --Cuenta los tipos de materiales para determinar si son Materiales / Servicios o la combinacion de ambas --  
    SET @CantidadTiposXAceptacion =
    (   SELECT COUNT(DISTINCT (tmp.Descripcion))
        FROM dbo.MM_AceptacionPedidoDetalle APD
            LEFT JOIN dbo.MM_PedidoDetalle PD
                ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
            LEFT JOIN dbo.MM_Material mat
                ON mat.IdMaterial = PD.IdMaterialVendedor
            LEFT JOIN dbo.MM_TipoMaterialProcura tmp
                ON mat.IdTipoCatalogoMaestro = tmp.IdTipoMaterialProcura
        WHERE IdAceptacionPedido = @IdAceptacionPedido);
    --Si son 2 Tipo de solicitud es igual a Bienes y servicios  
    IF (@CantidadTiposXAceptacion = 2)
    BEGIN
        DECLARE @TipoSolicitud NVARCHAR(MAX);
        SET @TipoSolicitud = N'Bienes y servicios';
    END;
    ELSE
    BEGIN
        --Si olo es 1 Tipo de solicitud es igual a la descripcion del tipo de material /servicio  

        SET @TipoSolicitud =
        (   SELECT DISTINCT
                   (tmp.Descripcion)
            FROM dbo.MM_AceptacionPedidoDetalle APD
                LEFT JOIN dbo.MM_PedidoDetalle PD
                    ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
                LEFT JOIN dbo.MM_Material mat
                    ON mat.IdMaterial = PD.IdMaterialVendedor
                LEFT JOIN dbo.MM_TipoMaterialProcura tmp
                    ON mat.IdTipoCatalogoMaestro = tmp.IdTipoMaterialProcura
            WHERE IdAceptacionPedido = @IdAceptacionPedido
                  AND mat.IdTipoCatalogoMaestro IS NOT NULL
            GROUP BY (tmp.Descripcion));
    END;




    /**Validacion bienes o servicio**/
    DECLARE @TablaIdsRepresentanteLegal TABLE (IdRepresentante INT);

    DECLARE @TablaRelacion TABLE
    (
        Carta NVARCHAR(MAX),
        DIA INT,
        MES NVARCHAR(100),
        ANIO INT,
        FECHA NVARCHAR(MAX),
        NombreOperadora NVARCHAR(MAX),
        RepresentanteLegal NVARCHAR(MAX),
        NombreProveedor NVARCHAR(MAX),
        NoActaConstitutiva NVARCHAR(MAX),
        Listado NVARCHAR(MAX),
        TipoInstrumento NVARCHAR(MAX),
        AnioFacturas INT,
        Domicilio NVARCHAR(MAX),
        IdAceptacionPedido INT
    );

    SET @IdTipoRegimen = (SELECT IdTipoRegimen FROM S_Proveedor WHERE IdProveedor = @IdProveedor);



    IF (@IdTipoRegimen = 2)
    BEGIN
        DECLARE @UsuarioFisico NVARCHAR(MAX) =
                (   SELECT TOP 1
                           U.Nombre AS RepresentanteLegal
                    FROM S_Proveedor AS P
                        JOIN S_UsuarioProveedor UP
                            ON P.IdProveedor = UP.IdProveedor
                        JOIN S_Usuario U
                            ON UP.IdUsuario = U.IdUsuario
                    WHERE U.IdTipoUsuario = 3
                          AND P.IdProveedor = @IdProveedor);
    END;

    DECLARE @RepresentanteLegal NVARCHAR(MAX);

    DECLARE @tablaAux TABLE
    (
        IdContrato INT,
        NombreContrato NVARCHAR(MAX),
        NombreOperadora NVARCHAR(MAX),
        IdAceptacionPedido INT
    );

    INSERT INTO @tablaAux (IdContrato, NombreContrato, NombreOperadora, IdAceptacionPedido)
    SELECT SP.IdContrato,
           N'Contrato ' + NumeroContrato,
           prov.RazonSocial,
           AP.IdAceptacionPedido
    FROM MM_SolicitudPedido AS SP
        INNER JOIN MM_PeticionOferta AS PO
            ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
        INNER JOIN MM_Pedido AS P
            ON P.IdPeticionOferta = PO.IdPeticionOferta
        INNER JOIN MM_AceptacionPedido AS AP
            ON AP.IdPedido = P.IdPedido
        INNER JOIN Adinco.dbo.CO_Contrato c
            ON c.IdContrato = SP.IdContrato
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = P.IdProveedorCompras
    WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;

    IF (@IdTipoRegimen = 2)
    BEGIN
        SET LANGUAGE spanish;

        INSERT INTO @TablaRelacion
        (
            Carta,
            DIA,
            MES,
            ANIO,
            FECHA,
            NombreOperadora,
            RepresentanteLegal,
            NombreProveedor,
            NoActaConstitutiva,
            Listado,
            TipoInstrumento,
            AnioFacturas,
            Domicilio,
            IdAceptacionPedido
        )
        SELECT TOP 1
               CONCAT(
               'Por medio de la presente, el (la) que suscribe ',
               @UsuarioFisico,
               ' representante(s) legal de la empresa ',
               CONCAT(P.RazonSocial, ' ', P.RegimenCapital),
               ' lo que acredito con el instrumento público número ',
               P.CURP,
               ' DECLARO BAJO PROTESTA DE DECIR VERDAD, que el (los) ',
               @TipoSolicitud,
               ' declarado(s), a continuación , se suministraron y facturaron al Operador del (de la) ',
               t.NombreContrato,
               ' en el año ',
               YEAR(GETDATE()),
               ' y que el cálculo de su Proporción de Contenido Nacional,se obtuvo de conformidad con lo señalado en el ',
               '“Acuerdo por el que se establece la Metodología para la Medición del Contenido Nacional en Asignaciones y ',
               'Contratos para la Exploración y Extracción de Hidrocarburos, así como para los permisos en la Industria de Hidrocarburos”, ',
               'y demás disposiciones jurídicas aplicables, además de que es correcta, completa, veraz y verificable.') AS Carta,
               DAY(GETDATE()) AS DIA,
               DATENAME(MONTH, DATEADD(MONTH, MONTH(GETDATE()), -1)) AS MES,
               RIGHT(CAST(YEAR(GETDATE()) AS CHAR(4)), 2) AS ANIO,
               'Ciudad de México, al ' + CAST(DAY(GETDATE()) AS NVARCHAR(2)) + ' de '
               + CAST(DATENAME(MONTH, DATEADD(MONTH, MONTH(GETDATE()), -1)) AS NVARCHAR(10)) + ' del '
               + CONVERT(NVARCHAR(10), YEAR(GETDATE())) AS FECHA,
               t.NombreOperadora AS NombreOperadora,
               @UsuarioFisico AS RepresentanteLegal,
               CONCAT(P.RazonSocial, ' ') AS NombreProveedor,
               P.CURP AS NoActaConstitutiva,
               @TipoSolicitud AS Listado,
               ---tsp.IdTipoSolicitudPedido (Este concepto ya es obsoleto)  
               t.NombreContrato AS TipoInstrumento,
               YEAR(GETDATE()) AS AnioFacturas,
               CONCAT(
               'Finalmente, se señala como domicilio para oír y recibir notificaciones relacionadas con lo dispuesto en el Acuerdo y demás disposiciones jurídicas aplicables, el ubicado en: ',
               domicilio.TipoViabilidad,
               ' ',
               domicilio.Calle,
               CASE
                   WHEN domicilio.NoExterior = '' THEN
                       ''
                   ELSE
                       ', No. Exterior ' + domicilio.NoExterior
               END,
               CASE
                   WHEN domicilio.NoInterior = '' THEN
                       ''
                   ELSE
                       ', No. Interior ' + domicilio.NoInterior
               END,
               CASE
                   WHEN domicilio.Colonia = '' THEN
                       ''
                   ELSE
                       ' Col. ' + domicilio.Colonia
               END,
               CASE
                   WHEN domicilio.Municipio = '' THEN
                       ''
                   ELSE
                       ', ' + domicilio.Municipio
               END,
               ' ',
               domicilio.Estado,
               ' ',
               domicilio.Pais,
               CASE
                   WHEN domicilio.CodigoPostal = '' THEN
                       ''
                   ELSE
                       ', C.P. ' + domicilio.CodigoPostal
               END,
               CASE
                   WHEN U.Correo = '' THEN
                       ''
                   ELSE
                       ', Correo Electronico Contacto: ' + U.Correo
               END,
               CASE
                   WHEN P.Telefono = '' THEN
                       ''
                   ELSE
                       ', Tel. ' + P.Telefono
               END) AS Domicilio,
               AP.IdAceptacionPedido
        FROM S_Proveedor P
            --LEFT JOIN DG_RepresentanteLegal RL  
            --    ON P.IdProveedor = RL.IdProveedor  
            --       AND RL.IsActivo = 1  
            --LEFT JOIN DG_ActaConstitutiva AC  
            --    ON P.IdProveedor = AC.IdProveedor  
            --       AND AC.IsActivo = 1  
            LEFT JOIN S_UsuarioProveedor UP
                ON P.IdProveedor = UP.IdProveedor
            LEFT JOIN S_Usuario U
                ON UP.IdUsuario = U.IdUsuario
            LEFT JOIN MM_Pedido MP
                ON MP.IdSubcontratista = P.IdProveedor
            LEFT JOIN MM_AceptacionPedido AS AP
                ON AP.IdPedido = MP.IdPedido
            --AND MP.IdUsuarioRecepcionServicio = U.IdUsuario  
            LEFT JOIN MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = MP.IdPeticionOferta
            LEFT JOIN MM_SolicitudPedido SP
                ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
            LEFT JOIN MM_TipoSolicitudPedido TSP
                ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido
            LEFT JOIN dbo.DG_Domicilio domicilio
                ON domicilio.IdProveedor = P.IdProveedor
                   AND domicilio.IdTipoDomicilio = 1
                   AND domicilio.Activo = 1
            INNER JOIN @tablaAux t
                ON AP.IdAceptacionPedido = t.IdAceptacionPedido
        WHERE P.IdProveedor = @IdProveedor
              AND AP.IdAceptacionPedido = @IdAceptacionPedido
              AND U.Activo = 1
        GROUP BY P.RazonSocial,
                 P.RegimenCapital,
                 --RL.Nombre,  
                 --RL.APaterno,  
                 --RL.AMaterno,  
                 --AC.Nombre,  
                 P.CURP,
                 TSP.TipoSolicitudPedido,
                 domicilio.TipoViabilidad,
                 domicilio.NombreViabilidad,
                 domicilio.NoExterior,
                 domicilio.NoInterior,
                 domicilio.Colonia,
                 domicilio.Municipio,
                 domicilio.Estado,
                 domicilio.Pais,
                 domicilio.CodigoPostal,
                 P.CorreoProveedor,
                 P.Telefono,
                 domicilio.Calle,
                 U.Correo,
                 U.IdTipoUsuario,
                 t.NombreOperadora,
                 t.NombreContrato,
                 AP.IdAceptacionPedido
        ORDER BY CASE
                     WHEN U.IdTipoUsuario = 3 THEN
                         '1'
                     ELSE
                         '2'
                 END ASC;
    END;
    ELSE
    BEGIN
        SET LANGUAGE spanish;

        INSERT INTO @TablaIdsRepresentanteLegal (IdRepresentante)
        SELECT splitdata
        FROM dbo.fnSplitString(@IdsRepresentanteLegal, ',');

        SELECT @RepresentanteLegal
            = STUFF(
              (   SELECT CAST(', ' AS VARCHAR(MAX))
                         + CONCAT(legal.Nombre, ' ', legal.APaterno, ' ', legal.AMaterno)
                  FROM dbo.DG_RepresentanteLegal legal
                      INNER JOIN @TablaIdsRepresentanteLegal carta
                          ON legal.IdRepresentanteLegal = carta.IdRepresentante
                  FOR XML PATH('')),
              1,
              1,
              '');

        DECLARE @NoActaConst NVARCHAR(MAX),
                @FechaActa NVARCHAR(MAX),
                @NoNotario NVARCHAR(MAX),
                @NombreNotario NVARCHAR(MAX),
                @UbicacionNotario NVARCHAR(MAX),
                @NumeroRppc NVARCHAR(MAX)


        SELECT @NoActaConst
            = CASE
                  WHEN NoActaConstitutiva IS NULL THEN
                      ''
                  ELSE
                      CONCAT(
                      'lo que acredito con el instrumento público número : ', NoActaConstitutiva)
              END,
               @FechaActa = CASE
                                WHEN Fecha IS NULL THEN
                                    ''
                                ELSE
                                    CONCAT(', de fecha: ', FORMAT(Fecha, 'dd-MMMM-yyyy'))
                            END,
               @NombreNotario = CASE
                                    WHEN NombreNotarioPublico IS NULL THEN
                                        ''
                                    ELSE
                                        CONCAT(', Notario: ', NombreNotarioPublico)
                                END,
               @NoNotario = CASE
                                WHEN NoNotario IS NULL THEN
                                    ''
                                ELSE
                                    CONCAT(', Notario Numero: ', NoNotario)
                            END,
               @UbicacionNotario = CASE
                                       WHEN LugarNotarioPublico IS NULL THEN
                                           ''
                                       ELSE
                                           CONCAT(', de ', LugarNotarioPublico)
                                   END,
               @NumeroRppc
                   = CASE
                         WHEN RPPC IS NULL THEN
                             ''
                         ELSE
                             CONCAT(', Registro Público de la Propiedad y Comercio Número: ', RPPC)
                     END
        FROM dbo.DG_ActaConstitutiva
        WHERE IdProveedor = @IdProveedor
              AND IsActivo = 1

        -- CASO ESPECIFICO PARA EL PROVEEDOR SWECOMEX
        IF @IdProveedor = 1961 -- SWECOMEX
        BEGIN
            SELECT @NoActaConst
                = CASE
                      WHEN NoEscrituraPublica IS NULL THEN
                          ''
                      ELSE
                          CONCAT(
                          'lo que acredito con el instrumento público número : ',
                          NoEscrituraPublica)
                  END,
                   @NombreNotario = CASE
                                        WHEN NombreNotario IS NULL THEN
                                            ''
                                        ELSE
                                            CONCAT(', Notario: ', NombreNotario)
                                    END,
                   @NoNotario = CASE
                                    WHEN NoNotario IS NULL THEN
                                        ''
                                    ELSE
                                        CONCAT(', Notario Número: ', NoNotario)
                                END,
                   @UbicacionNotario = CASE
                                           WHEN DireccionNotarioPublico IS NULL THEN
                                               ''
                                           ELSE
                                               CONCAT(', de ', DireccionNotarioPublico)
                                       END
            FROM dbo.DG_RepresentanteLegal
            WHERE IdProveedor = @IdProveedor
                  AND ISNULL(IsActivo, 0) = 1
        END



        INSERT INTO @TablaRelacion
        (
            Carta,
            DIA,
            MES,
            ANIO,
            FECHA,
            NombreOperadora,
            RepresentanteLegal,
            NombreProveedor,
            NoActaConstitutiva,
            Listado,
            TipoInstrumento,
            AnioFacturas,
            Domicilio,
            IdAceptacionPedido
        )
        SELECT TOP 1
               CONCAT(
               'Por medio de la presente, el (la) que suscribe ',
               @RepresentanteLegal,
               ' representante(s) legal de la empresa ',
               CONCAT(P.RazonSocial, ' ', P.RegimenCapital),
               @NoActaConst,
               @FechaActa,
               @NombreNotario,
               @NoNotario,
               @UbicacionNotario,
               @NumeroRppc,
               ', DECLARO BAJO PROTESTA DE DECIR VERDAD, que el (los) ',
               @TipoSolicitud,
               ' declarado(s), a continuación , se suministraron y facturaron al Operador del (de la) ',
               t.NombreContrato,
               ' en el año ',
               YEAR(GETDATE()),
               ' y que el cálculo de su Proporción de Contenido Nacional,se obtuvo de conformidad con lo señalado en el ',
               '“Acuerdo por el que se establece la Metodología para la Medición del Contenido Nacional en Asignaciones y ',
               'Contratos para la Exploración y Extracción de Hidrocarburos, así como para los permisos en la Industria de Hidrocarburos”, ',
               'y demás disposiciones jurídicas aplicables, además de que es correcta, completa, veraz y verificable.') AS Carta,
               DAY(GETDATE()) AS DIA,
               DATENAME(MONTH, DATEADD(MONTH, MONTH(GETDATE()), -1)) AS MES,
               RIGHT(CAST(YEAR(GETDATE()) AS CHAR(4)), 2) AS ANIO,
               'Ciudad de México, al ' + CAST(DAY(GETDATE()) AS NVARCHAR(2)) + ' de '
               + CAST(DATENAME(MONTH, DATEADD(MONTH, MONTH(GETDATE()), -1)) AS NVARCHAR(10)) + ' del '
               + CONVERT(NVARCHAR(10), YEAR(GETDATE())) AS FECHA,
               t.NombreOperadora AS NombreOperadora,
               @RepresentanteLegal AS RepresentanteLegal,
               CONCAT(P.RazonSocial, ' ', P.RegimenCapital) AS NombreProveedor,
               acta.NoActaConstitutiva AS NoActaConstitutiva,
               @TipoSolicitud AS Listado,
               t.NombreContrato AS TipoInstrumento,
               YEAR(GETDATE()) AS AnioFacturas,
               CONCAT(
               'Finalmente, se señala como domicilio para oír y recibir notificaciones relacionadas con lo dispuesto en el Acuerdo y demás disposiciones jurídicas aplicables, el ubicado en: ',
               domicilio.TipoViabilidad,
               ' ',
               domicilio.Calle,
               CASE
                   WHEN domicilio.NoExterior = '' THEN
                       ''
                   ELSE
                       ', No. Exterior ' + domicilio.NoExterior
               END,
               CASE
                   WHEN domicilio.NoInterior = '' THEN
                       ''
                   ELSE
                       ', No. Interior ' + domicilio.NoInterior
               END,
               CASE
                   WHEN domicilio.Colonia = '' THEN
                       ''
                   ELSE
                       ' Col. ' + domicilio.Colonia
               END,
               CASE
                   WHEN domicilio.Municipio = '' THEN
                       ''
                   ELSE
                       ', ' + domicilio.Municipio
               END,
               ' ',
               domicilio.Estado,
               ' ',
               domicilio.Pais,
               CASE
                   WHEN domicilio.CodigoPostal = '' THEN
                       ''
                   ELSE
                       ', C.P. ' + domicilio.CodigoPostal
               END,
               CASE
                   WHEN U.Correo = '' THEN
                       ''
                   ELSE
                       ', Correo Electronico Contacto: ' + U.Correo
               END,
               CASE
                   WHEN P.Telefono = '' THEN
                       ''
                   ELSE
                       ', Tel. ' + P.Telefono
               END) AS Domicilio,
               AP.IdAceptacionPedido
        FROM S_Proveedor P
            LEFT JOIN S_UsuarioProveedor UP
                ON P.IdProveedor = UP.IdProveedor
            INNER JOIN S_Usuario U
                ON UP.IdUsuario = U.IdUsuario
            LEFT JOIN dbo.DG_ActaConstitutiva acta
                ON acta.IdProveedor = P.IdProveedor
                   AND acta.IsActivo = 1
            LEFT JOIN MM_Pedido MP
                ON MP.IdSubcontratista = P.IdProveedor
            LEFT JOIN MM_AceptacionPedido AS AP
                ON AP.IdPedido = MP.IdPedido
            LEFT JOIN MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = MP.IdPeticionOferta
            LEFT JOIN MM_SolicitudPedido SP
                ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
            LEFT JOIN MM_TipoSolicitudPedido TSP
                ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido
            LEFT JOIN dbo.DG_Domicilio domicilio
                ON domicilio.IdProveedor = P.IdProveedor
                   AND domicilio.IdTipoDomicilio = 1
                   AND domicilio.Activo = 1
            INNER JOIN @tablaAux t
                ON AP.IdAceptacionPedido = t.IdAceptacionPedido
        WHERE P.IdProveedor = @IdProveedor
              AND AP.IdAceptacionPedido = @IdAceptacionPedido
              AND U.Activo = 1
        ORDER BY U.IdTipoUsuario;
    END;

    -- /////////////////////////////////////Seccion cabecera FIN  

    -- ////////////////////////////////////Seccion Detalle INICIO  
    DECLARE @IdMonedaNacional INT = 1;

    CREATE TABLE #ACTIVIDAD
    (
        IdRow INT,
        CodigoCatalogo NVARCHAR(MAX),
        NombreActividad NVARCHAR(MAX),
        ValorFactura MONEY,
        PCN FLOAT,
        IdTipoMaterial INT,
        DescPartidas NVARCHAR(MAX),
        IdAceptacionPedido INT
    );

    /*OBTENER TODOS LOS MATERIALES/SERVICIOS DE UNA ACEPTACIÓN DE PEDIDO Y AGREGARLOS A LA TABLA ACTIVIDA PARA LUEGO AGRUPARLOS POR TIP0 DE MATERIAL*/
    INSERT INTO #ACTIVIDAD
    (
        IdRow,
        CodigoCatalogo,
        NombreActividad,
        ValorFactura,
        PCN,
        IdTipoMaterial,
        DescPartidas,
        IdAceptacionPedido
    )
    SELECT ROW_NUMBER() OVER (ORDER BY BSA.Codigo ASC) AS IdRow,
           ISNULL(BSA.Codigo, 'NO CONTENIDO') AS CodigoCatalogo,
           ISNULL(BSA.Nombre, 'NO CONTENIDO') AS NombreActividad,
           ISNULL(V.ValorFactura, 0) AS ValorFactura,
           ROUND(APD.PCN, 3) AS PCN,
           V.IdTipoMaterialServicio AS IdTipoMaterial,
           POD.MaterialCotizadoTextoC,
           AP.IdAceptacionPedido
    FROM MM_AceptacionPedidoDetalle AS APD
        JOIN MM_AceptacionPedido AS AP
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
        JOIN dbo.MM_PCN_ValoresPesos AS V
            ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
        JOIN MM_PedidoDetalle AS PD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
        LEFT JOIN dbo.MM_BS_Actividad AS BSA
            ON BSA.IdActividad = V.IdCatalogoHidrocarburos
        INNER JOIN MM_Pedido AS P
            ON P.IdPedido = PD.IdPedido
        LEFT JOIN dbo.MM_Pedido AS PE
            ON PE.IdPedido = PD.IdPedido
               AND AP.IdPedido = PE.IdPedido
        LEFT JOIN MM_PeticionOfertaDetalle AS POD
            ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
    WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;

    CREATE TABLE #ACTIVIDAD_AGRUPADA
    (
        CodigoCatalogo NVARCHAR(MAX),
        NombreActividad NVARCHAR(MAX),
        CN FLOAT,
        MontoAcumulado MONEY,
        IdTipoMaterial INT,
        DescPartidas NVARCHAR(MAX),
        IdAceptacionPedido INT
    );

    /*AGRUPAR ACTIVIDAD POR TIPO DE MATERIAL(MATERIAL/SERVICIO)*/
    INSERT INTO #ACTIVIDAD_AGRUPADA
    (
        CodigoCatalogo,
        NombreActividad,
        CN,
        MontoAcumulado,
        IdTipoMaterial,
        DescPartidas,
        IdAceptacionPedido
    )
    SELECT CodigoCatalogo,
           NombreActividad,
           SUM(ValorFactura * PCN) AS CNB,
           SUM(ValorFactura) AS MontoAculadoFactura,
           IdTipoMaterial,
           '(' + NombreActividad + ') - '
           + STUFF(
             (   SELECT ' \ ' + SUBSTRING(DescPartidas, 1, 50)
                 FROM #ACTIVIDAD
                 WHERE (NombreActividad = ACT.NombreActividad)
                 FOR XML PATH(''), TYPE).value('(./text())[1]', 'VARCHAR(MAX)'),
             1,
             2,
             ''),
           ACT.IdAceptacionPedido
    FROM #ACTIVIDAD AS ACT
    WHERE IdTipoMaterial = 1 --> MATERIAL  
    GROUP BY CodigoCatalogo,
             IdTipoMaterial,
             NombreActividad,
             ACT.IdAceptacionPedido
    UNION ALL
    SELECT CodigoCatalogo,
           NombreActividad,
           SUM(ValorFactura * PCN) AS CNS,
           SUM(ValorFactura) AS MontoAculadoFactura,
           IdTipoMaterial,
           '(' + NombreActividad + ') - '
           + STUFF(
             (   SELECT ' \ ' + SUBSTRING([DescPartidas], 1, 50)
                 FROM #ACTIVIDAD
                 WHERE (NombreActividad = ACT.NombreActividad)
                 FOR XML PATH(''), TYPE).value('(./text())[1]', 'VARCHAR(MAX)'),
             1,
             2,
             ''),
           ACT.IdAceptacionPedido
    FROM #ACTIVIDAD AS ACT
    WHERE IdTipoMaterial = 2 --> SERVICIO  
    GROUP BY CodigoCatalogo,
             NombreActividad,
             IdTipoMaterial,
             IdAceptacionPedido;

    /*AGRUPADO POR ACTIVIDAD PCN DE CADA ACTIVIDAD*/
    DECLARE @Agrupada TABLE
    (
        CodigoCatalogo NVARCHAR(MAX),
        NombreActividad NVARCHAR(MAX),
        PorcentajeContenidoNacional FLOAT,
        MontoFacturado NVARCHAR(500),
        DescPartidas NVARCHAR(MAX),
        IdAceptacionPedido INT
    )

    INSERT INTO @Agrupada
    (
        CodigoCatalogo,
        NombreActividad,
        PorcentajeContenidoNacional,
        MontoFacturado,
        DescPartidas,
        IdAceptacionPedido
    )
    SELECT CodigoCatalogo,
           NombreActividad AS MaterialCotizadoTextoC,
           CASE
               WHEN ISNULL(SUM(CN), 0) > 0 THEN
                   CAST(SUBSTRING(
                        LTRIM(SUM(CN) / SUM(MontoAcumulado)),
                        1,
                        CHARINDEX('.', LTRIM(SUM(CN) / SUM(MontoAcumulado))) + 3) AS FLOAT)
               ELSE
                   0
           END AS PorcentajeContenidoNacional,
           LTRIM(ISNULL(CAST(SUM(MontoAcumulado) AS DECIMAL(34,4)), 0)) AS MontoFacturado,
           DescPartidas,
           IdAceptacionPedido
    FROM #ACTIVIDAD_AGRUPADA
    GROUP BY CodigoCatalogo,
             NombreActividad,
             DescPartidas,
             IdAceptacionPedido
    ORDER BY PorcentajeContenidoNacional DESC;

    -- ////////////////////////////////////Seccion Detalle FIN  

    SELECT t.Carta,
           t.DIA,
           t.MES,
           t.ANIO,
           t.FECHA,
           t.NombreOperadora,
           t.RepresentanteLegal,
           t.NombreProveedor,
           t.NoActaConstitutiva,
           t.Listado,
           t.TipoInstrumento,
           t.AnioFacturas,
           t.Domicilio,
           t.IdAceptacionPedido,
           agrupada.CodigoCatalogo,
           agrupada.NombreActividad,
           agrupada.PorcentajeContenidoNacional,
           CONCAT('$ ', CASE WHEN CHARINDEX('.' , agrupada.MontoFacturado) = 0 THEN agrupada.MontoFacturado ELSE (REPLACE(RTRIM(REPLACE(agrupada.MontoFacturado, '0', ' ')), ' ', '0')) END)  AS MontoFacturado, -- esto es para quitar los 0 de la derecha, teniendo en cuenta el caso de que no contenga punto decimal
           agrupada.DescPartidas,
           agrupada.IdAceptacionPedido
    FROM @TablaRelacion t
        INNER JOIN @Agrupada agrupada
            ON agrupada.IdAceptacionPedido = t.IdAceptacionPedido;
END;

