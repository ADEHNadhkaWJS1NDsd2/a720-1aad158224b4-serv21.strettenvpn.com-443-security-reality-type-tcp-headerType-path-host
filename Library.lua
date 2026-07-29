local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")

local Base64Data = "iVBORw0KGgoAAAANSUhEUgAAAYAAAAAgCAYAAAAbrK/lAAAVTUlEQVR42u1de9RVZZn/vd/5LqDcPkCdjCwtERxvhJ+mThYI6djCmVl5yRkQdS0cGnSV5spEWoJmjVpRmUkYoNhcNGtJNwEFtBgU0FnlqCkJs0bDULlJqHyXs3/zx3mefHjd17P3Od+F711rr7PPvryX533e5/682yFnIemcc8QBWEg2AHAAglrDgKQDUAIA51xXyD1XueXK6C/9pX74D+dc0A+NboG/E/izWztAcgrJ0oECdJIlHbu5/p5rNe6Ds4vwQEN8kg0C81I9Yd9f+ksPwP+SXfeyHhrrugaU4JP8B5Ib+joxUiB718aTnOxNRmORcFBiT3IAyQtIzjXXm+T8VpJrSd7lE8O+MicGyRtSPOP6IO6VZGx6dBvTE+brSI4j+RlLD/pLfYRuOR9KsjXqfj0Q8mCSr5Jc11cZgCB7o/nfQvI8kitJBqyU35GcQfIwj0uXCmi/JPC+je+Wheb+BeZ6QHKUvNPUV7QEH46C+GNJTpCjLWQhlPoI/pXS4Ed39Inkj0luF1xr6NfC6mZxOZ/kMpKvkdxJ8r9IXm0EQlfrjjTK73eE8Kzog9LmfgSc5GEkryX5P9y/lM35NpK3kzwuyWSUUsIqkWyWa4+R7CK5T9p6muRqkn+W//ukL1O8ukb1BQJIspnkNEH8bQYOWt6QhXAtyUOt9lQPPKkFAdT1JPW3kfw8yRtJziY5keTgukp+++PmaJJvC+yn9WSmK33u7UKQwn0Bo8takiNqig9mQZ5vpM7VRTEAo8YXduTsz3FC1LcZQHfJERgm0GXut5NcSnJyQTAfRPJlaS/wmI6V/gOSm0leSnKqaCl7Sc7sbYtA7fxyfhHJZ5m+bCM5p5ZmsChiV5DWZ8f+WZLPRIzzFZJzjOTXUId50fV/r8G7F4RB9zgtIMRW3uu0FAPzuQLzDkN/lB60y71HVCOrGScleSjJ1w0hWl0vBMy5qBIRQG3rYttfZgBLkp0RxNcS4U7v2jqSl1tpLQWXv4LkEyQXicS33tRPj+kEKQjia8JEesUC8Ajg/JDxPEdysSyIufLMem+uSHI5yeFF4qbngB9I8mQxQ42xEnterULOF6RkeGvNOF0dCNEnBPc6hRiR5A09TQswloovkFzSG5mAwbXDROOKW/M6F+emnQuXFaDOuS6SDwC4AEA7gBYAa5xzE0k2VBsSpuGkJIcCuAzA0Gr6aEog725xzt3nE1q/nwYpDgawAsDp5nYXKiGYaftCab/BvPMKgE8DeBaVcM0grE8kxwJ4PgfOBNI+AJQBNMn8nJVnfuqM8CXBs4UAZhhY/geAOwBs9ENh5d2xAC4GcB2AZrm8EcA5AHYB+ULmbMgzya9I3z4gtzsBvADgFufc/dXC2uDBAgD/LPU2AXgdwK8AvAxgGICzARwjc1yScZ4F4C0ArEVoIMmSc65Mcg2ATxjcLgN4U/qzIy+cC+prk3OuU5zUD8rlBQCuQiVsO8g659US75w4pzT3cgCLzHyHFaVTP3LOXaLzVTT3v9BIw11FaQDqbCW5gsWXm0gOIzmS5MAUGs5/C5dtTylhxxU1F7WTfF+UlGY0lIEi4eo7SVpHXFFt5NvSRktek1gd1d35Bn47SH7We65ZIqMGyrisqn+qzKGWJ/La6U3o6XDRLKzW58/P/Gqk4ZA11i51f1f9GubZFpJXkXzT+EO+Vysp3PTtk2acb5HcZf7PtZJ3D5D828RJWib5jvRxTloY5QmiKErLMGP5eoSFwac1JLm2UIuMZ/p5TQBaLooBGEAPF5u1qpadOY8O08edQki2kGwL669B8kUeAc1TysZs0RKHGCaaYpY3oXnb/m1viIox8P+Mgf9OkqfofbV3x8BPF0wryY2Ggc/PQxxN3x7wiLMPb8WZWVnbEybTIjZ1rftOSwzM4TxmoSaZ0bUwxxpn92pp71GJOGsl+Q2B82sk/8qa8LoRh5T4W9PIepIfTCMIGHPeiKzwNO8OMmZdl5MBXJOSAQQklxUqCJhOPOARpr8wABvtEnakZACtElbGAiTvuPI1JRgR47yuQAagMPplHCJ5Euy0FAwgCHFGx5WnxG5+fd3Cxarz0Qwg+QczpguMxN9gnj2N5JfFCTqF5CCrScr5kRIlpcLKmCyL2UZiyflFHkGJYrqdJPdIpExjSmlTCdd4M/Y3ZE2UQkJhbR7IatP+1UVL4aZvl5h2rjf3P2auL+kuX4Dp5/EhxH8nySPTzL/Bs5kkt5Icnxam5t1h4ry/L49WYOo7xqz5JI3/ssJwIML04xO3VQU5OlpFSi+aASgBeEfOoxiAjvXckBDPaovC69aoSTHjHyLhfS8ltB/ESPtpnr+yJ6jqEcz3n0w/7zeSry6EcRLu6ZfNJC8MYQKzzDM/zKD+N4RcezrFIrRz/s24+mIkPS2L4vqrmoBEfOk8P1QkATamL9VMFJfmGen2LDPufUKs6qoFGPxoNVFTlvi3pYGLsXZcbca6w7zfmLIPG8w8LpWcqYYqmYAK1vcb7TPw1reOdYswn1RaRxpOGEiC0x3GGeeXJhn0cPkdZn6HiWM3TXEpHK00Ts40z2mfSwAGyPnTxmHqvwMAWwDsy+GA9scEAL+Pcfopg3gOwCoAH46ZH0qdBLABwBpx/DXEwMXJWNvl/1EpFkHJLIa8R5qkuEDwbaqZt9t0nyNxjJ4I4FFUHPRlAOtl/HtkTPeTnK4OPqlvEYBXpc5zSbaKI9OlcMQ2SdLfYpK/BnCCwDJpLCXp/3TNS5D60hDl4eZ8s9nnKbSr4mD8XzPPrR4u5y3qzL5InLztpm3dAysw66kFwGy5XrfcBIFvKyoBHMeL87wkTumznXMbMzhFHYAT5XefzMkKkm3ikG1M0Yc2eRcAPipwqXZONKDlc7Lmm82a1ntNMtYLnXO7Zc0wL2BVIl6ZYJJQW+0u73eHHCclmD9U/R9sTEDlAjWAdRKqN0nVuQRNZLDYM4vQRNRfclqYBCLjHmRCGDtj2tTr20l+3NTxISNxlBP8AQtrYSPO4xgzcB9k4P6iOnflaBKbvmZen+6N/0G5t1dMP9ZEcq+Bw+kJUrVKcaMlvLKIsjXK7xSiAcwx730zTuo0kuEU887KoubXSP9DRSsNDJ7ONc9NMPShLFrA+DwO1LQajMEPK3V3GHyfFKbtJ41Zzn9gkix9TaIxQfJXp/MGFYDzmFxVCxYh+w6Sf/Kc8T8jeazxhbmiiP+/GKAG3pGmfC6lCqztXR6S6GCPPSb7NY7oKvN5huQJaT30BqHWFeCIVRjtsdmpIe01mZjvIGFc7STPMASg0TjQt0REpegY1ps2XQzxO4nkT8XRt0pszNUcq6SOldY8E9PuWEFmkrxbbf/ye7pcf9sQl4tJXifnA0lukme+JNcGyO9UA4vLYkxx2o+jjCDS6UW8ZZ1/a4Y4MQYGiv9nmfc3+U5f3+ktvz8y7d1UlHnP4NZcDxZRDMAGhjxWjSnK2+vGpWUURgCwzvkZ1cDCYwIL45hACuLfmjNAphRz71iSJyieZ3k3i+PhnQzIHnhSwrcy2FxVCmyR0LaoMpHk30RIu4qc3zdhnw1eFENaRrSkAEew9u/34txMkoBnmi0dopzJT4ZIIEoIbo/oc9nYBxvCGIAXhrqpBo73spFQoqKvJpnnNVxvoPzO1pBO+f+P5tk75dptgn8Pe3A50zx7cxhRMNLuQJJPFhgEYOt5PAoHDQ4M9ZIsZ3kRQCUbDSXM2uLMaUX4AAw+DBdndNmLQoliABZXP5mlL2atHkZytu1HSiLdYfo3Iw8cPOYSyQTqQfwFL08jeYMw45tEU7xGjuvl2jxJHD1PE0+TmGhjQuNfFZvfW2JPs3a9JlSSpnxbd5fYqB51zl0jCy1LMsLBAHaGvEOxc78G4OgIO6f2YYXYwax9Lm0ftI4XirB6qE/BObdPEOE9djnxATQ65xaIpDwB0Qkfb4eNXereG+PrCQB8CMBM59z3wxBD+tEE4NAaWIAakJzcx5B50NIs93X8R5h7o834Hd5NAgurK4ixdZdJTgRwquBxUU5yXQNnAjjJOfe0nygmsC85594k+V0ANwPoAPB1kjucc//p1VkmeSqAxYInDeI/2lBQApDC44sARkr/sxKyeQLPVARXbOhDASwDcCrJI5xzM4XhBSYJLyxZsEvmuVFw/G5NBqvKcVeZj0BgeQVJSDvt4mdZQXICgE0AVgI4WWz+A1BJyjvbObcrR0KgJt2dDeB28WtkKVtJ3uqcu0PpTiafgHCdQ0IcuiPk9xchJhI9f0aey+z1Fs471HMmtxqJvkTylhAJLTA24FHVbMJWg0igxAggX8oxdu5yhIa12ySUNdt9P4zkmuQHWBC2X4ipZ6rsPbRdpJ08x3aRIL8RFRli2m0z2qPav1vk9zwjfen47yT5MMlD5L9GB90e8S5Jfj5CA9B5X+rF87NgLeCaGBOUaiHNkrxmI1lWinl0kuRJLPX6uJvk+9OaT1KsfScWgHYj/dtxzDXayMQQvFNacEkKU4bVNp71JOmF1t/haXbzDYwUTguKMoGl0AS2SmSYvVak5D8jZJuZNIelyQuz+FTSdrBFCISddLU97yR5fBFqaEz7N4YwAO3HRubYItcQozFib87jBFY/xqUJDMBXZZMI+HpNUDF1JL1r1fd2cbjG+UIGhjDhrIe+OzSl+W+YCQPeaCKI1FH+R7n3IMkhXh03mLk62WMA8w0cJkQ443UOHi8oCS+KAXw1jTAgxHB9ynDgXSSPlhDZh43TMS8BujcEFjqOG83zYSZZZRovGGe+S3A2HyyMjdx/nyHLBJo94mj9EguNucwVSG/CmIDNBWmvAfGf5O0kUI3Jtd3OVWZ6HJLQpXHH4z2pwDq7zs/LgaOSyQznnxvCAPT8O3na9yKBdnjjrDYJLDLyxDjavmUkiTQx/VvknbkM3ywuqrxiNJLEpLQiQ/VSSJ1NMpZAJMAPe/Nuv33wohn/OnN9viEWykCeN1LyB6Kc8fL7WI0ZwJwk/DR9GcLKNhD7YupdLhFLpxjm+WS1hMi0fbTBxSCEsG8i+fdi/18ewagyaQEhwkyHzwTk/hWmvQ4vaKAm30eIYAK25Cb+pp0m8RsWEYTSJTD6SO61bYjVlzyk1kn4QpaQqxztz4tJSrusAAakjtJlKTI/k4j/qyIFRzmzdExXpkj2ikv6StIaXhJVfUiGCIvCjgxze63p+y0h0RaXmyxPH17zzfxpfZ8yROuXMYzY34OoaBOQhgNPTCONeQRxDCs7Wv5EIquWixZsQ2HXmJDAqgkS37vlRVfOMQeCe0OTTMIxkrauv/msbHXuE/8njBZR8+8/yPm/i8lxiZi8iyD+JRPxFhSciPrl3KYxYxu0UpI2cE+RtrcEIvGVCB9AOwvYC8UQrkOMd78zI+KrvfqUBGn7L3ZN8eYvZmXbhjRtpAlR1HvTainhF7S4HCv7Te0wKuy4ECZwlEQ//IKVzQP/VRyidvuGBpIHmfh1xhFfg1s3MXnPlTzhwCPT2ujT2G6NljPSaIJVRaLwvRu+JRH/joSIPfpRQ2kYXwQTKEeYMzeIuawu37sweNpgwowHF7GuEuhbXjP0o7n6aAjVCC9GWu21B9WBAyti/NRDUEUO/TCFK2KiQ0K8OjJI/juTkn/ixsnKBm4sQArQ/sxSMwt6aDHzO9uM3UpXjQlmhJIXHnuPgcOKBEasbU+vgQagCVKx4cAJRL7RM2s1mj6H4WpmJmDqW8PoLS80GGEbyTNIHs74JESVZN/QsOyM8f0LPVt/h0f8W7tTqDGwL4LmKAO4uUAhROfw8bwMwH4MIjBceQdTbrJUlB1ZNJCy6YNGKtxTpPM5IsmjMyPxb8yCAMZx+e2chEg1hHbp13Pi2O3RH8QwRO4Rz7462jzTJIRUo6Ba1DlobOeLzfuJu1Qaya7F5EG0GydcnkPncHqtgiPyJiR56ztO8NCx2M3gxie80+U5I9NsqpZkc3+d7yZXdsfGc65I4u8xgC/WQAP4WS5Ymc7dZqThoKjEk4xIvi5isJcWbYbyFtbymIlRJN9UDfEPaW+VMWt1GSkyTxnbU01AIYR4BPffUGs3K/vfD0lgoH8rDmKmNcOFwL5NQvyKLAuYIhGxO5gA99/w7akUPqVA6lNz1uIU0UplmcOPMOVGcR4T+Ddxbl8tfrWTu4v412H+jilovVtaFeobzfKhcodKIsgGAOPk3ZnOuR9IElNXPYiDJGiMQ+WrSH55yjn3Z+b4ik/UxJgNxmziiQJTzzcCOMc5t7OaZBzu/1WyzUiXkKVt6ELQZL0NqHxB6ggAxwJYAuBuhHyNrCcuBLOx1s8BnGFuvwxgNYBfA/g/uTYMwMcBfErGquVPAP4uy0ZgBscOATBL6tUkxEzDkN83AdzlnHukaLxMATu7KZkmKE2WZDP7dTNNOpoO4B7Ef3XK4thLALYD+Bj2TxINK7pGljrnpmeZD0OrBjrn3iI50jm3vR7w7CYmQJm7yciXkKgbxW0H8Nfym/0LZUbVeb9wcZK8q9ZO3542MTF2SV/CKuVsp4GVbSH2SgLQVIl+2Mz992EKi7sOJEdjUB+Rhpok+mNfRsnnVyQPr2Y+ahQG67oBdmGawLPiNN3PhCHa0/PGzl5OOPwQ7KTnNRzxbZJHVwtnuz1CH6YzTkKgd3rWlixBB3ZTyfNzm3+kUxdLhQ/b691FjEMOV+N2o+yShRD/kPZGef+nGJ9Hl0kKW29yCLr47kZczSaRqqEXLgYbCnmcwPzlGMTfRfIhkpPzEnNDFOuxFXa9mADp7U0fE4Zcy/ITG6rbXTb3XiD8tIm5yw8lTjosY47dE8ml7JCqiD9GZT+TMaLaoqebE2pElHSflPtQ2Tf8TOfcbhb40XWjyuv+JgGA96HycXktdzvnrvBMU0Bl75DrtJ99Bd7yfwiAk1DZ//+D8thuAM8A+INz7o+WSPQ1E0GVODRMTGa/c85N80xd+vtRVPZqqsc+/gGAtb0dN+s0d4cDmAfgHACjUr6+B8BjAL7mnFsfZ25zGRbhIAC/AXCVc+43RRK7XiyZOgAHOef21gIenu9BfTDfQ2VjqN86564Uzh7IIp6Lykdlfg75cEdfIYAiFbkkopH2uQOQkAxCZSM9HuiMsbfNnZwPRsX3Woqh3cq8X3TObfXrqIoBGAQ6EcCRzrmHWMxug32KIXTHgrJSbl90iMVpBCG4S8hXqvoxMjt+KuOsV5/66Ud1GnBWM1LSesgSBdTknOs8kCX/OAJcxzZLRooLvHtqUy33S3j9pbtxtb/URPBJ9XhaGv3/ClYhnusuFesAAAAASUVORK5CYII="
local Base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function DecodeBase64(Data)
    Data = Data:gsub("[^" .. Base64Alphabet .. "=]", "")
    return (Data:gsub(".", function(Character)
        if Character == "=" then
            return ""
        end
        local Value = Base64Alphabet:find(Character, 1, true) - 1
        local Bits = ""
        for Index = 6, 1, -1 do
            Bits ..= Value % 2 ^ Index - Value % 2 ^ (Index - 1) > 0 and "1" or "0"
        end
        return Bits
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(Bits)
        if #Bits ~= 8 then
            return ""
        end
        local Value = 0
        for Index = 1, 8 do
            if Bits:sub(Index, Index) == "1" then
                Value += 2 ^ (8 - Index)
            end
        end
        return string.char(Value)
    end))
end

local function ResolveIconAsset()
    local CustomAsset = getcustomasset or getsynasset
    if type(writefile) ~= "function" or type(CustomAsset) ~= "function" then
        return nil
    end
    local FileName = "AtramentaReferenceIcons.png"
    local Exists = type(isfile) == "function" and isfile(FileName)
    if not Exists then
        writefile(FileName, DecodeBase64(Base64Data))
    end
    local Success, Asset = pcall(CustomAsset, FileName)
    if Success then
        return Asset
    end
    return nil
end

local IconAsset = ResolveIconAsset()
local IconIndexes = {
    Lightning = 0,
    Pistol = 1,
    Shield = 2,
    Gear = 3,
    Minus = 4,
    Target = 5,
    Cloud = 6,
    Search = 7,
    Warning = 8,
    Check = 9,
    Chevron = 10,
    User = 11
}

local Accent = Color3.fromRGB(112, 139, 255)
local Background = Color3.fromRGB(7, 8, 15)
local SidebarColor = Color3.fromRGB(14, 15, 25)
local Surface = Color3.fromRGB(10, 11, 19)
local SurfaceAlt = Color3.fromRGB(13, 15, 24)
local Border = Color3.fromRGB(27, 30, 43)
local PrimaryText = Color3.fromRGB(226, 230, 242)
local MutedText = Color3.fromRGB(101, 106, 127)
local DisabledText = Color3.fromRGB(57, 61, 77)
local Danger = Color3.fromRGB(255, 91, 104)
local BaseScaleFactor = 1
local AnimationFactor = 1

local Menu = {
    Flags = {},
    Setters = {},
    Connections = {},
    Visible = true,
    Pages = {},
    SidebarButtons = {},
    ModeButtons = {},
    Sections = {},
    BindRuntime = {},
    BindSystem = {}
}

do
    local GlowBase64Data = "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"
    local CustomAsset = getcustomasset or getsynasset
    if type(writefile) == "function" and type(CustomAsset) == "function" then
        local GlowFileName = "AtramentaReferenceGlow.png"
        local GlowExists = type(isfile) == "function" and isfile(GlowFileName)
        if not GlowExists then
            pcall(function()
                writefile(GlowFileName, DecodeBase64(GlowBase64Data))
            end)
        end
        local Success, Asset = pcall(CustomAsset, GlowFileName)
        if Success then
            Menu.GlowAsset = Asset
        end
    end
end

local function Create(ClassName, Properties)
    local Object = Instance.new(ClassName)
    for Property, Value in pairs(Properties or {}) do
        Object[Property] = Value
    end
    return Object
end

local function Corner(Parent, Radius)
    return Create("UICorner", {
        Parent = Parent,
        CornerRadius = UDim.new(0, Radius)
    })
end

local function Stroke(Parent, Color, Transparency, Thickness)
    return Create("UIStroke", {
        Parent = Parent,
        Color = Color,
        Transparency = Transparency or 0,
        Thickness = Thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

local function Bind(Connection)
    table.insert(Menu.Connections, Connection)
    return Connection
end

function Menu:AddSoftGlow(Target, ZIndex, Padding, Transparency, UseSlice)
    if not self.GlowAsset or not Target or not Target.Parent then
        return nil
    end

    local Extra = Padding or 8
    local Glow = Create("ImageLabel", {
        Parent = Target.Parent,
        AnchorPoint = Target.AnchorPoint,
        Position = Target.Position,
        Size = UDim2.new(Target.Size.X.Scale, Target.Size.X.Offset + Extra * 2, Target.Size.Y.Scale, Target.Size.Y.Offset + Extra * 2),
        BackgroundTransparency = 1,
        Image = self.GlowAsset,
        ImageColor3 = Accent,
        ImageTransparency = Transparency or 0.72,
        ScaleType = UseSlice == false and Enum.ScaleType.Fit or Enum.ScaleType.Slice,
        SliceCenter = Rect.new(34, 34, 62, 62),
        ZIndex = (ZIndex or Target.ZIndex) - 1
    })

    local function Sync()
        if not Target.Parent or not Glow.Parent then
            return
        end
        local Anchor = Target.AnchorPoint
        Glow.AnchorPoint = Anchor
        Glow.Position = UDim2.new(
            Target.Position.X.Scale,
            Target.Position.X.Offset + math.floor((Extra * ((Anchor.X * 2) - 1)) + 0.5),
            Target.Position.Y.Scale,
            Target.Position.Y.Offset + math.floor((Extra * ((Anchor.Y * 2) - 1)) + 0.5)
        )
        Glow.Size = UDim2.new(Target.Size.X.Scale, Target.Size.X.Offset + Extra * 2, Target.Size.Y.Scale, Target.Size.Y.Offset + Extra * 2)
    end

    Sync()
    Bind(Target:GetPropertyChangedSignal("Position"):Connect(Sync))
    Bind(Target:GetPropertyChangedSignal("Size"):Connect(Sync))
    Bind(Target.AncestryChanged:Connect(function(_, ParentObject)
        if not ParentObject and Glow.Parent then
            Glow:Destroy()
        end
    end))

    return Glow
end

local function Tween(Object, Duration, Properties)
    local Animation = TweenService:Create(
        Object,
        TweenInfo.new((Duration or 0.15) / math.max(AnimationFactor, 0.05), Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        Properties
    )
    Animation:Play()
    return Animation
end

local function SmoothSlider(FrameObject, KnobObject, Alpha, Duration)
    Alpha = math.clamp(Alpha or 0, 0, 1)
    if FrameObject then
        Tween(FrameObject, Duration or 0.12, {Size = UDim2.new(Alpha, 0, 1, 0)})
    end
    if KnobObject then
        Tween(KnobObject, Duration or 0.12, {Position = UDim2.new(Alpha, 0, 0.5, 0)})
    end
end

local function CreateFallbackIcon(Parent, Name, Size, Position, Color, ZIndex)
    local Root = Create("Frame", {
        Parent = Parent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = Position,
        Size = Size,
        BackgroundTransparency = 1,
        ZIndex = ZIndex
    })

    local function Line(PositionValue, SizeValue, Rotation)
        local Object = Create("Frame", {
            Parent = Root,
            Position = PositionValue,
            Size = SizeValue,
            Rotation = Rotation or 0,
            BackgroundColor3 = Color,
            BorderSizePixel = 0,
            ZIndex = ZIndex + 1
        })
        Corner(Object, 3)
        return Object
    end

    if Name == "Minus" then
        Line(UDim2.new(0.18, 0, 0.44, 0), UDim2.new(0.64, 0, 0.12, 0))
    elseif Name == "Target" then
        local Outer = Create("Frame", {
            Parent = Root,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.8, 0.8),
            BackgroundTransparency = 1,
            ZIndex = ZIndex + 1
        })
        Corner(Outer, 100)
        Stroke(Outer, Color, 0, 1)
        local Dot = Create("Frame", {
            Parent = Root,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.2, 0.2),
            BackgroundColor3 = Color,
            BorderSizePixel = 0,
            ZIndex = ZIndex + 2
        })
        Corner(Dot, 100)
    elseif Name == "Gear" then
        local Ring = Create("Frame", {
            Parent = Root,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.65, 0.65),
            BackgroundTransparency = 1,
            ZIndex = ZIndex + 1
        })
        Corner(Ring, 100)
        Stroke(Ring, Color, 0, 2)
        for Index = 0, 3 do
            Line(UDim2.new(0.45, 0, 0.05, 0), UDim2.new(0.1, 0, 0.9, 0), Index * 45)
        end
    elseif Name == "Lightning" then
        Line(UDim2.new(0.42, 0, 0.02, 0), UDim2.new(0.2, 0, 0.55, 0), 18)
        Line(UDim2.new(0.25, 0, 0.39, 0), UDim2.new(0.5, 0, 0.18, 0), -18)
        Line(UDim2.new(0.40, 0, 0.43, 0), UDim2.new(0.2, 0, 0.55, 0), 18)
    else
        local Box = Create("Frame", {
            Parent = Root,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.55, 0.55),
            BackgroundTransparency = 1,
            ZIndex = ZIndex + 1
        })
        Corner(Box, 2)
        Stroke(Box, Color, 0, 1)
    end

    return Root
end

local function Icon(Parent, Name, Size, Position, Color, ZIndex)
    if not IconAsset then
        return CreateFallbackIcon(Parent, Name, Size, Position, Color, ZIndex)
    end
    return Create("ImageLabel", {
        Parent = Parent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = Position,
        Size = Size,
        BackgroundTransparency = 1,
        Image = IconAsset,
        ImageRectOffset = Vector2.new(IconIndexes[Name] * 32, 0),
        ImageRectSize = Vector2.new(32, 32),
        ImageColor3 = Color,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = ZIndex
    })
end

local Parent = CoreGui
pcall(function()
    if gethui then
        Parent = gethui()
    end
end)

local PositionFile = "AtramentaReferencePositions.json"
local SavedPositions = {}

local function EncodePosition(Position)
    return {
        XScale = Position.X.Scale,
        XOffset = Position.X.Offset,
        YScale = Position.Y.Scale,
        YOffset = Position.Y.Offset
    }
end

local function DecodePosition(Data, Fallback)
    if type(Data) ~= "table" then
        return Fallback
    end

    local XScale = tonumber(Data.XScale)
    local XOffset = tonumber(Data.XOffset)
    local YScale = tonumber(Data.YScale)
    local YOffset = tonumber(Data.YOffset)

    if not XScale or not XOffset or not YScale or not YOffset then
        return Fallback
    end

    return UDim2.new(XScale, XOffset, YScale, YOffset)
end

local function LoadPositions()
    if type(isfile) ~= "function" or type(readfile) ~= "function" or not isfile(PositionFile) then
        return
    end

    local Success, Data = pcall(function()
        return HttpService:JSONDecode(readfile(PositionFile))
    end)

    if Success and type(Data) == "table" then
        SavedPositions = Data
    end
end

local function SavePositions()
    if type(writefile) ~= "function" then
        return
    end

    pcall(function()
        writefile(PositionFile, HttpService:JSONEncode(SavedPositions))
    end)
end

LoadPositions()

if type(SavedPositions.AccentHex) == "string" then
    local Hex = SavedPositions.AccentHex:gsub("#", "")
    if #Hex == 6 then
        local Red = tonumber(Hex:sub(1, 2), 16)
        local Green = tonumber(Hex:sub(3, 4), 16)
        local Blue = tonumber(Hex:sub(5, 6), 16)
        if Red and Green and Blue then
            Accent = Color3.fromRGB(Red, Green, Blue)
        end
    end
end

local AccentAlpha = math.clamp(tonumber(SavedPositions.AccentAlpha) or 1, 0, 1)
local ThemeColors = type(SavedPositions.ThemeColors) == "table" and SavedPositions.ThemeColors or {"#C9A35B", "#59B9B4", "#A65AC7"}

pcall(function()
    local Existing = Parent:FindFirstChild("AtramentaReferenceMenuV11")
    if Existing then
        Existing:Destroy()
    end
end)

local ScreenGui = Create("ScreenGui", {
    Name = "AtramentaReferenceMenuV11",
    Parent = Parent,
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
end)

local Overlay = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.fromScale(1, 1),
    Active = true,
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.55,
    BorderSizePixel = 0,
    ZIndex = 0
})

local InputBlocker = Create("TextButton", {
    Parent = ScreenGui,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    Visible = false,
    Modal = true,
    ZIndex = 1
})

local Main = Create("Frame", {
    Parent = ScreenGui,
    Active = true,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = DecodePosition(SavedPositions.Main, UDim2.fromScale(0.5, 0.535)),
    Size = UDim2.fromOffset(744, 610),
    BackgroundColor3 = Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2
})
Corner(Main, 8)
Stroke(Main, Border, 0.08, 1)

local MainScale = Create("UIScale", {
    Parent = Main,
    Scale = 1
})

local Sidebar = Create("Frame", {
    Parent = Main,
    Size = UDim2.fromOffset(102, 610),
    BackgroundColor3 = SidebarColor,
    BorderSizePixel = 0,
    ZIndex = 3
})

Create("Frame", {
    Parent = Sidebar,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BackgroundColor3 = Border,
    BorderSizePixel = 0,
    ZIndex = 4
})

Icon(Sidebar, "Lightning", UDim2.fromOffset(36, 48), UDim2.fromOffset(55, 42), Accent, 6)

Create("Frame", {
    Parent = Sidebar,
    Position = UDim2.fromOffset(27, 92),
    Size = UDim2.fromOffset(56, 1),
    BackgroundColor3 = Border,
    BorderSizePixel = 0,
    ZIndex = 5
})

local Content = Create("Frame", {
    Parent = Main,
    Position = UDim2.fromOffset(102, 0),
    Size = UDim2.new(1, -102, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 3
})

local Topbar = Create("Frame", {
    Parent = Content,
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Color3.fromRGB(8, 9, 16),
    BorderSizePixel = 0,
    ZIndex = 4
})

local DragArea = Create("Frame", {
    Parent = Topbar,
    Size = UDim2.new(1, -100, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 5
})

local function CreateModeButton(Name, X)
    local Button = Create("TextButton", {
        Parent = Topbar,
        Position = UDim2.fromOffset(X, 17),
        Size = UDim2.fromOffset(92, 32),
        BackgroundColor3 = SurfaceAlt,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.BuilderSansMedium,
        Text = Name,
        TextColor3 = MutedText,
        TextSize = 12,
        ZIndex = 6
    })
    Corner(Button, 6)
    Menu.ModeButtons[Name] = Button
    return Button
end

local RagebotMode = CreateModeButton("Ragebot", 14)
local LegitbotMode = CreateModeButton("Legitbot", 110)

local SaveButton = Create("TextButton", {
    Parent = Topbar,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -14, 0, 17),
    Size = UDim2.fromOffset(62, 32),
    BackgroundColor3 = SurfaceAlt,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.BuilderSansMedium,
    Text = "Save",
    TextColor3 = PrimaryText,
    TextSize = 12,
    ZIndex = 6
})
Corner(SaveButton, 6)
Stroke(SaveButton, Border, 0.45, 1)

local SearchBar = Create("Frame", {
    Parent = Content,
    Position = UDim2.fromOffset(14, 76),
    Size = UDim2.fromOffset(564, 48),
    BackgroundColor3 = Surface,
    BorderSizePixel = 0,
    ZIndex = 5
})
Corner(SearchBar, 6)
Stroke(SearchBar, Border, 0.4, 1)

local SearchBox = Create("TextBox", {
    Parent = SearchBar,
    Position = UDim2.fromOffset(14, 0),
    Size = UDim2.new(1, -54, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSans,
    PlaceholderText = "Search",
    PlaceholderColor3 = DisabledText,
    Text = "",
    TextColor3 = PrimaryText,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 6
})

Icon(SearchBar, "Search", UDim2.fromOffset(17, 17), UDim2.new(1, -18, 0.5, 0), MutedText, 7)

local SearchSettings = Create("TextButton", {
    Parent = Content,
    Position = UDim2.fromOffset(584, 76),
    Size = UDim2.fromOffset(50, 48),
    BackgroundColor3 = Surface,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    ZIndex = 5
})
Corner(SearchSettings, 6)
local SearchSettingsStroke = Stroke(SearchSettings, Border, 0.4, 1)
local SearchSettingsIcon = Icon(SearchSettings, "Gear", UDim2.fromOffset(20, 20), UDim2.fromScale(0.5, 0.5), MutedText, 7)
local SearchSettingsOpened = false

local function UpdateSettingsButtonAppearance(State, Instant)
    SearchSettingsOpened = State and true or false
    local TargetBackground = State and Accent or Surface
    local TargetStroke = State and Accent or Border
    local TargetIcon = State and PrimaryText or MutedText
    SearchSettings.ZIndex = State and 27 or 5
    SearchSettingsIcon.ZIndex = State and 29 or 7
    if Instant then
        SearchSettings.BackgroundColor3 = TargetBackground
        SearchSettingsStroke.Color = TargetStroke
        SearchSettingsStroke.Transparency = State and 0 or 0.4
        SearchSettingsIcon.ImageColor3 = TargetIcon
    else
        Tween(SearchSettings, 0.14, {BackgroundColor3 = TargetBackground})
        Tween(SearchSettingsStroke, 0.14, {Color = TargetStroke, Transparency = State and 0 or 0.4})
        Tween(SearchSettingsIcon, 0.14, {ImageColor3 = TargetIcon})
    end
end

Bind(SearchSettings.MouseEnter:Connect(function()
    if not SearchSettingsOpened then
        Tween(SearchSettings, 0.12, {BackgroundColor3 = Color3.fromRGB(17, 19, 31)})
        Tween(SearchSettingsStroke, 0.12, {Transparency = 0.25})
        Tween(SearchSettingsIcon, 0.12, {ImageColor3 = PrimaryText})
    end
end))

Bind(SearchSettings.MouseLeave:Connect(function()
    if not SearchSettingsOpened then
        UpdateSettingsButtonAppearance(false)
    end
end))

UpdateSettingsButtonAppearance(false, true)

local PageHolder = Create("Frame", {
    Parent = Content,
    Position = UDim2.fromOffset(14, 136),
    Size = UDim2.fromOffset(626, 464),
    BackgroundTransparency = 1,
    ZIndex = 4
})

local SidebarDefinitions = {
    {"Combat", "Pistol", 116},
    {"Misc", "Shield", 184},
    {"Settings", "Gear", 252},
    {"Visuals", "Minus", 338},
    {"Players", "Target", 406},
    {"Cloud", "Cloud", 474},
    {"Config", "Gear", 542}
}

for _, Definition in ipairs(SidebarDefinitions) do
    local Name, IconName, Y = Definition[1], Definition[2], Definition[3]
    local Button = Create("TextButton", {
        Parent = Sidebar,
        Position = UDim2.fromOffset(28, Y),
        Size = UDim2.fromOffset(54, 48),
        BackgroundColor3 = SidebarColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 5
    })
    Corner(Button, 10)

    local Marker = Create("Frame", {
        Parent = Sidebar,
        Position = UDim2.fromOffset(0, Y + 10),
        Size = UDim2.fromOffset(2, 28),
        BackgroundColor3 = Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 7
    })
    Corner(Marker, 2)

    local IconObject = Icon(Button, IconName, UDim2.fromOffset(20, 20), UDim2.fromScale(0.5, 0.5), MutedText, 7)

    Menu.SidebarButtons[Name] = {
        Button = Button,
        Marker = Marker,
        Icon = IconObject
    }
end

local function CreatePage(Name)
    local Page = Create("Frame", {
        Parent = PageHolder,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 4
    })
    Menu.Pages[Name] = Page
    return Page
end

local function CreateSection(Page, Key, Title, Position, Size)
    local Root = Create("Frame", {
        Parent = Page,
        Position = Position,
        Size = Size,
        BackgroundColor3 = Surface,
        BorderSizePixel = 0,
        ZIndex = 5
    })
    Corner(Root, 5)
    Stroke(Root, Border, 0.32, 1)

    Create("TextLabel", {
        Parent = Root,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -24, 0, 36),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = Title,
        TextColor3 = MutedText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    })

    Create("Frame", {
        Parent = Root,
        Position = UDim2.fromOffset(10, 36),
        Size = UDim2.new(1, -20, 0, 1),
        BackgroundColor3 = Border,
        BorderSizePixel = 0,
        ZIndex = 6
    })

    local Body = Create("Frame", {
        Parent = Root,
        Position = UDim2.fromOffset(10, 42),
        Size = UDim2.new(1, -20, 1, -50),
        BackgroundTransparency = 1,
        ZIndex = 6
    })

    Create("UIListLayout", {
        Parent = Body,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local Section = {
        Root = Root,
        Body = Body,
        Controls = {},
        HomePosition = Position
    }
    Menu.Sections[Key] = Section
    return Section
end

local function CreateRow(Parent, Height)
    return Create("Frame", {
        Parent = Parent,
        Size = UDim2.new(1, 0, 0, Height),
        BackgroundTransparency = 1,
        ZIndex = 7
    })
end

local function RegisterControl(Section, Row, Name)
    table.insert(Section.Controls, {
        Row = Row,
        Name = string.lower(Name)
    })
end

local ActiveGearMenu
local ActiveGearBindMenu
local ActiveGearHotkeysMenu
local ActiveGearButton
local ActiveGearButtonIcon
local ActiveGearMeta
local ActiveGearBindEntry
local ActiveGearHotkeysEntry
local PendingBindCapture
local CloseGearMenus
local OpenGearMenu

local function CreateGear(Row, XOffset, YOffset, ControlName, ControlFlag, ControlInfo)
    local Button = Create("TextButton", {
        Parent = Row,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, XOffset, 0, YOffset or 13),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Active = true,
        Text = "",
        ZIndex = 11
    })
    local GearIcon = Icon(Button, "Gear", UDim2.fromOffset(14, 14), UDim2.fromScale(0.5, 0.5), MutedText, 12)
    local Meta = {
        Name = ControlName,
        Flag = ControlFlag,
        Row = Row,
        Button = Button,
        Icon = GearIcon,
        Info = ControlInfo or {}
    }
    Bind(Button.MouseButton1Click:Connect(function()
        if OpenGearMenu then
            OpenGearMenu(Button, GearIcon, Meta)
        end
    end))
    return Button, GearIcon
end

local function CreateWarning(Row)
    return nil
end

local function CreateCheckbox(Row, Default)
    local Button = Create("TextButton", {
        Parent = Row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = Default and Accent or SurfaceAlt,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 9
    })
    Corner(Button, 3)
    local BorderStroke = Stroke(Button, Default and Accent or Border, 0, 1)
    local Check = Icon(Button, "Check", UDim2.fromOffset(10, 10), UDim2.fromScale(0.5, 0.5), Color3.fromRGB(13, 15, 23), 10)
    Check.Visible = Default
    return Button, BorderStroke, Check
end

local function CreateToggle(Section, Name, Default, Flag, Options)
    Options = Options or {}
    local Row = CreateRow(Section.Body, 27)

    if Options.Warning then
        CreateWarning(Row)
    end

    Create("TextLabel", {
        Parent = Row,
        Position = UDim2.fromOffset(Options.Warning and 15 or 0, 0),
        Size = UDim2.new(1, Options.Warning and -58 or -43, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = Name,
        TextColor3 = Options.Disabled and DisabledText or PrimaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    })

    if Options.Gear then
        CreateGear(Row, -38, 13, Name, Flag, {Type = "Boolean"})
    end

    local Button, BorderStroke, Check = CreateCheckbox(Row, Default)
    local State = Default and true or false
    Menu.Flags[Flag] = State

    local function Set(Value)
        State = Value and true or false
        Menu.Flags[Flag] = State
        Check.Visible = State
        Tween(Button, 0.12, {
            BackgroundColor3 = State and Accent or SurfaceAlt
        })
        Tween(BorderStroke, 0.12, {
            Color = State and Accent or Border
        })
        if type(Options.Callback) == "function" then
            task.spawn(Options.Callback, State)
        end
    end

    Menu.Setters[Flag] = Set

    Bind(Button.MouseButton1Click:Connect(function()
        Set(not State)
    end))

    Bind(Row.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local RelativeX = Input.Position.X - Row.AbsolutePosition.X
            local RightExclusion = Options.Gear and 52 or 24
            if RelativeX < Row.AbsoluteSize.X - RightExclusion then
                Set(not State)
            end
        end
    end))

    RegisterControl(Section, Row, Name)
    return {
        Set = Set,
        Get = function()
            return State
        end
    }
end

local function CreateValueBox(Parent, TextValue, XOffset)
    local Box = Create("Frame", {
        Parent = Parent,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, XOffset, 0, 0),
        Size = UDim2.fromOffset(34, 20),
        BackgroundColor3 = SurfaceAlt,
        BorderSizePixel = 0,
        ZIndex = 8
    })
    Corner(Box, 3)
    local Label = Create("TextLabel", {
        Parent = Box,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = TextValue,
        TextColor3 = PrimaryText,
        TextSize = 11,
        ZIndex = 9
    })
    return Label
end

local function CreateSlider(Section, Name, Minimum, Maximum, Default, Flag, Options)
    Options = Options or {}
    local Row = CreateRow(Section.Body, 47)

    Create("TextLabel", {
        Parent = Row,
        Size = UDim2.new(1, -60, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = Name,
        TextColor3 = Options.Disabled and DisabledText or PrimaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    })

    if Options.Gear then
        CreateGear(Row, -43, 9, Name, Flag, {Type = "Number", Minimum = Minimum, Maximum = Maximum, Decimals = Options.Decimals})
    end

    local ValueLabel
    if Options.Box then
        ValueLabel = CreateValueBox(Row, tostring(Default), 0)
    else
        ValueLabel = Create("TextLabel", {
            Parent = Row,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(48, 18),
            BackgroundTransparency = 1,
            Font = Enum.Font.BuilderSans,
            Text = tostring(Default),
            TextColor3 = MutedText,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 8
        })
    end

    local Track = Create("Frame", {
        Parent = Row,
        Position = UDim2.fromOffset(0, 31),
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = Color3.fromRGB(28, 31, 45),
        BorderSizePixel = 0,
        ZIndex = 8
    })
    Corner(Track, 2)

    local Fill = Create("Frame", {
        Parent = Track,
        Size = UDim2.new((Default - Minimum) / (Maximum - Minimum), 0, 1, 0),
        BackgroundColor3 = Accent,
        BorderSizePixel = 0,
        ZIndex = 9
    })
    Corner(Fill, 2)

    local Knob = Create("Frame", {
        Parent = Track,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((Default - Minimum) / (Maximum - Minimum), 0, 0.5, 0),
        Size = UDim2.fromOffset(6, 14),
        BackgroundColor3 = Color3.fromRGB(218, 224, 247),
        BorderSizePixel = 0,
        ZIndex = 10
    })
    Corner(Knob, 2)

    local Value = Default
    local Dragging = false
    Menu.Flags[Flag] = Value

    local function Format(Number)
        if Options.Decimals then
            return string.format("%." .. tostring(Options.Decimals) .. "f", Number)
        end
        return tostring(math.floor(Number + 0.5))
    end

    local function Set(NewValue)
        NewValue = math.clamp(NewValue, Minimum, Maximum)
        if Options.Decimals then
            local Power = 10 ^ Options.Decimals
            NewValue = math.floor(NewValue * Power + 0.5) / Power
        else
            NewValue = math.floor(NewValue + 0.5)
        end
        Value = NewValue
        Menu.Flags[Flag] = Value
        local Alpha = (Value - Minimum) / (Maximum - Minimum)
        SmoothSlider(Fill, Knob, Alpha, 0.12)
        ValueLabel.Text = Format(Value) .. tostring(Options.Suffix or "")
        if type(Options.Callback) == "function" then
            task.spawn(Options.Callback, Value)
        end
    end

    Menu.Setters[Flag] = Set

    local function Update(Input)
        local Alpha = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Set(Minimum + (Maximum - Minimum) * Alpha)
    end

    Bind(Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Update(Input)
        end
    end))

    Bind(UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(Input)
        end
    end))

    Bind(UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end))

    RegisterControl(Section, Row, Name)
    return {
        Set = Set,
        Get = function()
            return Value
        end
    }
end

local function CreateDualSlider(Section, Name, Minimum, Maximum, DefaultMinimum, DefaultMaximum, MinimumFlag, MaximumFlag)
    local Row = CreateRow(Section.Body, 51)

    Create("TextLabel", {
        Parent = Row,
        Size = UDim2.new(1, -128, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = Name,
        TextColor3 = PrimaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    })

    CreateGear(Row, -86, 10, Name, MinimumFlag, {Type = "Number", Minimum = Minimum, Maximum = Maximum})
    local MinimumLabel = CreateValueBox(Row, tostring(DefaultMinimum), -41)
    local MaximumLabel = CreateValueBox(Row, tostring(DefaultMaximum), 0)

    local Track = Create("Frame", {
        Parent = Row,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = Color3.fromRGB(28, 31, 45),
        BorderSizePixel = 0,
        ZIndex = 8
    })
    Corner(Track, 2)

    local MinimumAlpha = (DefaultMinimum - Minimum) / (Maximum - Minimum)
    local MaximumAlpha = (DefaultMaximum - Minimum) / (Maximum - Minimum)

    local Fill = Create("Frame", {
        Parent = Track,
        Position = UDim2.new(MinimumAlpha, 0, 0, 0),
        Size = UDim2.new(MaximumAlpha - MinimumAlpha, 0, 1, 0),
        BackgroundColor3 = Accent,
        BorderSizePixel = 0,
        ZIndex = 9
    })
    Corner(Fill, 2)

    local MinimumKnob = Create("Frame", {
        Parent = Track,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(MinimumAlpha, 0, 0.5, 0),
        Size = UDim2.fromOffset(6, 14),
        BackgroundColor3 = Color3.fromRGB(218, 224, 247),
        BorderSizePixel = 0,
        ZIndex = 10
    })
    Corner(MinimumKnob, 2)

    local MaximumKnob = Create("Frame", {
        Parent = Track,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(MaximumAlpha, 0, 0.5, 0),
        Size = UDim2.fromOffset(6, 14),
        BackgroundColor3 = Color3.fromRGB(218, 224, 247),
        BorderSizePixel = 0,
        ZIndex = 10
    })
    Corner(MaximumKnob, 2)

    local Low = DefaultMinimum
    local High = DefaultMaximum
    local ActiveKnob
    Menu.Flags[MinimumFlag] = Low
    Menu.Flags[MaximumFlag] = High

    local function Refresh()
        local LowAlpha = (Low - Minimum) / (Maximum - Minimum)
        local HighAlpha = (High - Minimum) / (Maximum - Minimum)
        MinimumKnob.Position = UDim2.new(LowAlpha, 0, 0.5, 0)
        MaximumKnob.Position = UDim2.new(HighAlpha, 0, 0.5, 0)
        Fill.Position = UDim2.new(LowAlpha, 0, 0, 0)
        Fill.Size = UDim2.new(HighAlpha - LowAlpha, 0, 1, 0)
        MinimumLabel.Text = tostring(Low)
        MaximumLabel.Text = tostring(High)
        Menu.Flags[MinimumFlag] = Low
        Menu.Flags[MaximumFlag] = High
    end

    Menu.Setters[MinimumFlag] = function(Value)
        Low = math.clamp(math.floor(tonumber(Value) or Low + 0.5), Minimum, High)
        Refresh()
    end
    Menu.Setters[MaximumFlag] = function(Value)
        High = math.clamp(math.floor(tonumber(Value) or High + 0.5), Low, Maximum)
        Refresh()
    end

    local function Update(Input)
        local Alpha = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local Value = math.floor(Minimum + (Maximum - Minimum) * Alpha + 0.5)
        if ActiveKnob == MinimumKnob then
            Low = math.min(Value, High)
        else
            High = math.max(Value, Low)
        end
        Refresh()
    end

    local function Begin(Input, Knob)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            ActiveKnob = Knob
            Update(Input)
        end
    end

    Bind(MinimumKnob.InputBegan:Connect(function(Input)
        Begin(Input, MinimumKnob)
    end))

    Bind(MaximumKnob.InputBegan:Connect(function(Input)
        Begin(Input, MaximumKnob)
    end))

    Bind(Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local Alpha = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            local Value = Minimum + (Maximum - Minimum) * Alpha
            ActiveKnob = math.abs(Value - Low) <= math.abs(Value - High) and MinimumKnob or MaximumKnob
            Update(Input)
        end
    end))

    Bind(UserInputService.InputChanged:Connect(function(Input)
        if ActiveKnob and Input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(Input)
        end
    end))

    Bind(UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            ActiveKnob = nil
        end
    end))

    RegisterControl(Section, Row, Name)
end

local ActivePopup
local ActivePopupCleanup

local function ClosePopup()
    if ActivePopupCleanup then
        pcall(ActivePopupCleanup)
        ActivePopupCleanup = nil
    end
    if ActivePopup then
        ActivePopup:Destroy()
        ActivePopup = nil
    end
end

local function SetGearIconColor(IconObject, Color)
    if not IconObject then
        return
    end
    pcall(function()
        if IconObject:IsA("ImageLabel") or IconObject:IsA("ImageButton") then
            IconObject.ImageColor3 = Color
            return
        end
    end)
    for _, Descendant in ipairs(IconObject:GetDescendants()) do
        if Descendant:IsA("ImageLabel") or Descendant:IsA("ImageButton") then
            Descendant.ImageColor3 = Color
        elseif Descendant:IsA("Frame") and Descendant.BackgroundTransparency < 1 then
            Descendant.BackgroundColor3 = Color
        elseif Descendant:IsA("UIStroke") then
            Descendant.Color = Color
        end
    end
end

do
local function GetControlBinds(ControlFlag)
    SavedPositions.ControlBinds = SavedPositions.ControlBinds or {}
    local Key = tostring(ControlFlag or "Unknown")
    local Binds = SavedPositions.ControlBinds[Key]
    if type(Binds) ~= "table" then
        Binds = {}
        SavedPositions.ControlBinds[Key] = Binds
    end
    return Binds, Key
end

local function ApplyFlagValue(Flag, Value)
    local Setter = Menu.Setters[Flag]
    if Setter then
        Setter(Value)
    else
        Menu.Flags[Flag] = Value
    end
end

local function SetGearIconColor(IconObject, Color)
    if not IconObject then
        return
    end
    pcall(function()
        if IconObject:IsA("ImageLabel") or IconObject:IsA("ImageButton") then
            IconObject.ImageColor3 = Color
        end
    end)
    for _, Descendant in ipairs(IconObject:GetDescendants()) do
        if Descendant:IsA("ImageLabel") or Descendant:IsA("ImageButton") then
            Descendant.ImageColor3 = Color
        elseif Descendant:IsA("Frame") and Descendant.BackgroundTransparency < 1 then
            Descendant.BackgroundColor3 = Color
        elseif Descendant:IsA("UIStroke") then
            Descendant.Color = Color
        end
    end
end

local function IsModifierKey(KeyCode)
    return KeyCode == Enum.KeyCode.LeftControl
        or KeyCode == Enum.KeyCode.RightControl
        or KeyCode == Enum.KeyCode.LeftShift
        or KeyCode == Enum.KeyCode.RightShift
        or KeyCode == Enum.KeyCode.LeftAlt
        or KeyCode == Enum.KeyCode.RightAlt
end

local function ReadModifiers()
    return {
        Ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl),
        Shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift),
        Alt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
    }
end

local function FriendlyKeyName(Name)
    local Result = tostring(Name or "Unknown")
    Result = Result:gsub("MouseButton1", "Mouse 1")
    Result = Result:gsub("MouseButton2", "Mouse 2")
    Result = Result:gsub("MouseButton3", "Mouse 3")
    Result = Result:gsub("Keypad", "Num ")
    Result = Result:gsub("(%l)(%u)", "%1 %2")
    Result = Result:gsub("One", "1")
    Result = Result:gsub("Two", "2")
    Result = Result:gsub("Three", "3")
    Result = Result:gsub("Four", "4")
    Result = Result:gsub("Five", "5")
    Result = Result:gsub("Six", "6")
    Result = Result:gsub("Seven", "7")
    Result = Result:gsub("Eight", "8")
    Result = Result:gsub("Nine", "9")
    Result = Result:gsub("Zero", "0")
    return Result
end

local function BuildBindDisplay(KeyName, Modifiers)
    local Parts = {}
    if Modifiers and Modifiers.Ctrl then
        table.insert(Parts, "Ctrl")
    end
    if Modifiers and Modifiers.Shift then
        table.insert(Parts, "Shift")
    end
    if Modifiers and Modifiers.Alt then
        table.insert(Parts, "Alt")
    end
    table.insert(Parts, FriendlyKeyName(KeyName))
    return table.concat(Parts, " + ")
end

local function GetInputIdentity(Input)
    if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode ~= Enum.KeyCode.Unknown then
        return "KeyCode", Input.KeyCode.Name
    end
    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.MouseButton2
        or Input.UserInputType == Enum.UserInputType.MouseButton3 then
        return "UserInputType", Input.UserInputType.Name
    end
    return nil, nil
end

local function ModifiersEqual(Expected)
    Expected = Expected or {}
    local Current = ReadModifiers()
    return Current.Ctrl == (Expected.Ctrl == true)
        and Current.Shift == (Expected.Shift == true)
        and Current.Alt == (Expected.Alt == true)
end

local function BindMatchesInput(BindData, Input, CheckModifiers)
    local KeyType, KeyName = GetInputIdentity(Input)
    if not KeyType or BindData.KeyType ~= KeyType or BindData.Key ~= KeyName then
        return false
    end
    if CheckModifiers == false then
        return true
    end
    return ModifiersEqual(BindData.Modifiers)
end

local function FormatBindLabel(BindData)
    local Display = BindData.Display or BuildBindDisplay(BindData.Key, BindData.Modifiers)
    return Display .. "   |   " .. tostring(BindData.Mode or "Toggle")
end

local function AddPopupShadow(Target, ZIndex)
    return Menu:AddSoftGlow(Target, ZIndex, 9, 0.64, true)
end

local function ClampPopupPosition(FrameObject, Position)
    local Camera = workspace.CurrentCamera
    local Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    local Size = FrameObject.AbsoluteSize
    if Size.X <= 0 or Size.Y <= 0 then
        Size = Vector2.new(FrameObject.Size.X.Offset, FrameObject.Size.Y.Offset)
    end
    local X = math.clamp(Position.X.Offset, 8, math.max(8, Viewport.X - Size.X - 8))
    local Y = math.clamp(Position.Y.Offset, 8, math.max(8, Viewport.Y - Size.Y - 8))
    return UDim2.fromOffset(math.floor(X + 0.5), math.floor(Y + 0.5))
end

local function RectsOverlap(A, B)
    if not A or not B or not A.Parent or not B.Parent then
        return false
    end
    local AP, AS = A.AbsolutePosition, A.AbsoluteSize
    local BP, BS = B.AbsolutePosition, B.AbsoluteSize
    return AP.X < BP.X + BS.X and AP.X + AS.X > BP.X and AP.Y < BP.Y + BS.Y and AP.Y + AS.Y > BP.Y
end

local function PlacePopup(FrameObject, PreferredPosition, Peers)
    local Position = ClampPopupPosition(FrameObject, PreferredPosition)
    FrameObject.Position = Position
    for _, Peer in ipairs(Peers or {}) do
        if Peer and Peer.Parent and RectsOverlap(FrameObject, Peer) then
            local Gap = 8
            local Candidates = {
                UDim2.fromOffset(Peer.AbsolutePosition.X + Peer.AbsoluteSize.X + Gap, Position.Y.Offset),
                UDim2.fromOffset(Peer.AbsolutePosition.X - FrameObject.AbsoluteSize.X - Gap, Position.Y.Offset),
                UDim2.fromOffset(Position.X.Offset, Peer.AbsolutePosition.Y + Peer.AbsoluteSize.Y + Gap),
                UDim2.fromOffset(Position.X.Offset, Peer.AbsolutePosition.Y - FrameObject.AbsoluteSize.Y - Gap)
            }
            for _, Candidate in ipairs(Candidates) do
                local CandidatePosition = ClampPopupPosition(FrameObject, Candidate)
                FrameObject.Position = CandidatePosition
                if not RectsOverlap(FrameObject, Peer) then
                    Position = CandidatePosition
                    break
                end
            end
        end
    end
    return FrameObject.Position
end

local function MakePopupDraggable(FrameObject, Height)
    local Handle = Create("TextButton", {
        Parent = FrameObject,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, Height or 14),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Active = true,
        ZIndex = FrameObject.ZIndex + 20
    })

    local Grip = Create("Frame", {
        Parent = Handle,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 5),
        Size = UDim2.fromOffset(24, 2),
        BackgroundColor3 = Border,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = Handle.ZIndex + 1
    })
    Corner(Grip, 2)

    local Dragging = false
    local DragStart
    local StartPosition

    Bind(Handle.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPosition = FrameObject.Position
        end
    end))

    Bind(UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            FrameObject.Position = ClampPopupPosition(FrameObject, UDim2.fromOffset(StartPosition.X.Offset + Delta.X, StartPosition.Y.Offset + Delta.Y))
        end
    end))

    Bind(UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end))
end

local function CreateGlyph(ParentObject, Kind, Color, Position)
    local Root = Create("Frame", {
        Parent = ParentObject,
        Position = Position or UDim2.fromOffset(10, 8),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = ParentObject.ZIndex + 2
    })

    local function Line(X, Y, W, H)
        local Object = Create("Frame", {
            Parent = Root,
            Position = UDim2.fromOffset(X, Y),
            Size = UDim2.fromOffset(W, H),
            BackgroundColor3 = Color,
            BorderSizePixel = 0,
            ZIndex = Root.ZIndex + 1
        })
        Corner(Object, 2)
        return Object
    end

    local function Outline(X, Y, W, H)
        local Object = Create("Frame", {
            Parent = Root,
            Position = UDim2.fromOffset(X, Y),
            Size = UDim2.fromOffset(W, H),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = Root.ZIndex + 1
        })
        Corner(Object, 2)
        Stroke(Object, Color, 0, 1)
        return Object
    end

    if Kind == "Bind" then
        Outline(1, 4, 4, 4)
        Line(5, 6, 6, 1)
        Line(8, 7, 1, 2)
        Line(10, 7, 1, 2)
    elseif Kind == "Hotkeys" then
        Line(1, 2, 10, 1)
        Line(1, 6, 10, 1)
        Line(1, 10, 10, 1)
        Line(3, 0, 2, 4)
        Line(7, 4, 2, 4)
        Line(4, 8, 2, 4)
    elseif Kind == "Reset" then
        Line(2, 3, 8, 1)
        Line(5, 1, 2, 1)
        Outline(3, 4, 6, 7)
        Line(5, 6, 1, 3)
        Line(7, 6, 1, 3)
    end
    return Root
end

local function CreateMenuEntry(ParentObject, Y, TextValue, GlyphKind, TextColor, Arrow)
    local Entry = Create("TextButton", {
        Parent = ParentObject,
        Position = UDim2.fromOffset(7, Y),
        Size = UDim2.new(1, -14, 0, 27),
        BackgroundColor3 = Color3.fromRGB(23, 26, 39),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = ParentObject.ZIndex + 2
    })
    Corner(Entry, 5)
    CreateGlyph(Entry, GlyphKind, TextColor, UDim2.fromOffset(8, 7))

    Create("TextLabel", {
        Parent = Entry,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, Arrow and -44 or -34, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = TextValue,
        TextColor3 = TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Entry.ZIndex + 2
    })

    if Arrow then
        local ArrowIcon = Icon(Entry, "Chevron", UDim2.fromOffset(8, 8), UDim2.new(1, -10, 0.5, 0), TextColor, Entry.ZIndex + 2)
        ArrowIcon.Rotation = -90
    end

    Bind(Entry.MouseEnter:Connect(function()
        Tween(Entry, 0.10, {BackgroundTransparency = 0})
    end))
    Bind(Entry.MouseLeave:Connect(function()
        if not Entry:GetAttribute("Selected") then
            Tween(Entry, 0.10, {BackgroundTransparency = 1})
        end
    end))
    return Entry
end

local function SetEntrySelected(Entry, State)
    if not Entry or not Entry.Parent then
        return
    end
    Entry:SetAttribute("Selected", State and true or false)
    Tween(Entry, 0.10, {BackgroundTransparency = State and 0 or 1})
end

CloseGearMenus = function()
    PendingBindCapture = nil
    if ActiveGearMenu then
        ActiveGearMenu:Destroy()
        ActiveGearMenu = nil
    end
    if ActiveGearBindMenu then
        ActiveGearBindMenu:Destroy()
        ActiveGearBindMenu = nil
    end
    if ActiveGearHotkeysMenu then
        ActiveGearHotkeysMenu:Destroy()
        ActiveGearHotkeysMenu = nil
    end
    if ActiveGearButtonIcon then
        SetGearIconColor(ActiveGearButtonIcon, MutedText)
    end
    ActiveGearButton = nil
    ActiveGearButtonIcon = nil
    ActiveGearMeta = nil
    ActiveGearBindEntry = nil
    ActiveGearHotkeysEntry = nil
end

local function OpenHotkeysMenu(SourceEntry)
    if ActiveGearHotkeysMenu then
        ActiveGearHotkeysMenu:Destroy()
        ActiveGearHotkeysMenu = nil
        SetEntrySelected(SourceEntry, false)
        return
    end
    if not ActiveGearMenu or not ActiveGearMeta then
        return
    end

    ActiveGearHotkeysEntry = SourceEntry
    SetEntrySelected(SourceEntry, true)
    local Binds = GetControlBinds(ActiveGearMeta.Flag)
    local ContentHeight = math.max(32, #Binds * 34)
    local Height = math.min(214, 42 + ContentHeight)

    ActiveGearHotkeysMenu = Create("Frame", {
        Parent = ScreenGui,
        Active = true,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(208, Height),
        BackgroundColor3 = Color3.fromRGB(11, 13, 22),
        BorderSizePixel = 0,
        ZIndex = 170
    })
    Corner(ActiveGearHotkeysMenu, 7)
    if AddPopupShadow then
        AddPopupShadow(ActiveGearHotkeysMenu, 170)
    end
    Stroke(ActiveGearHotkeysMenu, Border, 0.08, 1)

    local Preferred = UDim2.fromOffset(ActiveGearMenu.AbsolutePosition.X + ActiveGearMenu.AbsoluteSize.X + 8, ActiveGearMenu.AbsolutePosition.Y + 42)
    PlacePopup(ActiveGearHotkeysMenu, Preferred, {ActiveGearBindMenu, ActiveGearMenu})
    MakePopupDraggable(ActiveGearHotkeysMenu, 14)

    Create("TextLabel", {
        Parent = ActiveGearHotkeysMenu,
        Position = UDim2.fromOffset(11, 14),
        Size = UDim2.new(1, -22, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = "Hotkeys",
        TextColor3 = PrimaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 172
    })

    local List = Create("ScrollingFrame", {
        Parent = ActiveGearHotkeysMenu,
        Position = UDim2.fromOffset(8, 38),
        Size = UDim2.new(1, -16, 1, -46),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, ContentHeight),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Accent,
        ZIndex = 171
    })

    if #Binds == 0 then
        Create("TextLabel", {
            Parent = List,
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Font = Enum.Font.BuilderSans,
            Text = "No binds",
            TextColor3 = DisabledText,
            TextSize = 10,
            ZIndex = 172
        })
        return
    end

    for Index, BindData in ipairs(Binds) do
        local Row = Create("Frame", {
            Parent = List,
            Position = UDim2.fromOffset(0, (Index - 1) * 34),
            Size = UDim2.new(1, -3, 0, 30),
            BackgroundColor3 = Color3.fromRGB(17, 19, 30),
            BorderSizePixel = 0,
            ZIndex = 172
        })
        Corner(Row, 5)
        Stroke(Row, Border, 0.42, 1)

        Create("TextLabel", {
            Parent = Row,
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.new(1, -38, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.BuilderSansMedium,
            Text = FormatBindLabel(BindData),
            TextColor3 = PrimaryText,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 173
        })

        local Remove = Create("TextButton", {
            Parent = Row,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.BuilderSansMedium,
            Text = "×",
            TextColor3 = DisabledText,
            TextSize = 13,
            ZIndex = 174
        })
        Bind(Remove.MouseButton1Click:Connect(function()
            table.remove(Binds, Index)
            SavePositions()
            ActiveGearHotkeysMenu:Destroy()
            ActiveGearHotkeysMenu = nil
            OpenHotkeysMenu(SourceEntry)
        end))
    end
end

local function CreateValueControl(ParentObject, Meta, InitialValue, OnChanged)
    local Info = Meta.Info or {}
    if Info.Type == "Boolean" or type(InitialValue) == "boolean" then
        local State = InitialValue == true
        local Button = Create("TextButton", {
            Parent = ParentObject,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -11, 0, 88),
            Size = UDim2.fromOffset(13, 13),
            BackgroundColor3 = State and Accent or SurfaceAlt,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 182
        })
        Corner(Button, 3)
        local ButtonStroke = Stroke(Button, State and Accent or Border, 0, 1)
        local Check = Icon(Button, "Check", UDim2.fromOffset(9, 9), UDim2.fromScale(0.5, 0.5), Color3.fromRGB(13, 15, 23), 183)
        Check.Visible = State
        Bind(Button.MouseButton1Click:Connect(function()
            State = not State
            Check.Visible = State
            Button.BackgroundColor3 = State and Accent or SurfaceAlt
            ButtonStroke.Color = State and Accent or Border
            OnChanged(State)
        end))
        OnChanged(State)
        return
    end

    if Info.Type == "Number" or type(InitialValue) == "number" then
        local Minimum = tonumber(Info.Minimum) or 0
        local Maximum = tonumber(Info.Maximum) or math.max(100, tonumber(InitialValue) or 100)
        local Value = math.clamp(tonumber(InitialValue) or Minimum, Minimum, Maximum)
        local Track = Create("Frame", {
            Parent = ParentObject,
            Position = UDim2.fromOffset(12, 96),
            Size = UDim2.fromOffset(112, 4),
            BackgroundColor3 = Color3.fromRGB(28, 31, 45),
            BorderSizePixel = 0,
            ZIndex = 182
        })
        Corner(Track, 2)
        local Fill = Create("Frame", {
            Parent = Track,
            BackgroundColor3 = Accent,
            BorderSizePixel = 0,
            ZIndex = 183
        })
        Corner(Fill, 2)
        local Knob = Create("Frame", {
            Parent = Track,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(6, 13),
            BackgroundColor3 = Color3.fromRGB(220, 225, 245),
            BorderSizePixel = 0,
            ZIndex = 184
        })
        Corner(Knob, 2)
        local ValueLabel = Create("TextLabel", {
            Parent = ParentObject,
            Position = UDim2.fromOffset(132, 84),
            Size = UDim2.fromOffset(32, 20),
            BackgroundColor3 = Color3.fromRGB(17, 19, 30),
            BorderSizePixel = 0,
            Font = Enum.Font.BuilderSansMedium,
            TextColor3 = PrimaryText,
            TextSize = 10,
            ZIndex = 182
        })
        Corner(ValueLabel, 4)
        local Dragging = false
        local function Set(ValueInput)
            Value = math.clamp(tonumber(ValueInput) or Value, Minimum, Maximum)
            if Info.Decimals then
                local Power = 10 ^ Info.Decimals
                Value = math.floor(Value * Power + 0.5) / Power
            else
                Value = math.floor(Value + 0.5)
            end
            local Alpha = (Value - Minimum) / math.max(0.0001, Maximum - Minimum)
            SmoothSlider(Fill, Knob, Alpha, 0.12)
            ValueLabel.Text = tostring(Value)
            OnChanged(Value)
        end
        local function Update(Input)
            local Alpha = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            Set(Minimum + (Maximum - Minimum) * Alpha)
        end
        Bind(Track.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                Update(Input)
            end
        end))
        Bind(UserInputService.InputChanged:Connect(function(Input)
            if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(Input)
            end
        end))
        Bind(UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end))
        Set(Value)
        return
    end

    local Values = Info.Values or {}
    local Current = InitialValue
    local Button = Create("TextButton", {
        Parent = ParentObject,
        Position = UDim2.fromOffset(92, 84),
        Size = UDim2.fromOffset(72, 22),
        BackgroundColor3 = Color3.fromRGB(17, 19, 30),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.BuilderSansMedium,
        Text = tostring(Current),
        TextColor3 = PrimaryText,
        TextSize = 10,
        ZIndex = 182
    })
    Corner(Button, 4)
    Bind(Button.MouseButton1Click:Connect(function()
        local Index = table.find(Values, Current) or 0
        Index = (Index % math.max(1, #Values)) + 1
        Current = Values[Index] or Current
        Button.Text = tostring(Current)
        OnChanged(Current)
    end))
    OnChanged(Current)
end

local function OpenGearBindMenu(SourceEntry)
    if ActiveGearBindMenu then
        ActiveGearBindMenu:Destroy()
        ActiveGearBindMenu = nil
        SetEntrySelected(SourceEntry, false)
        return
    end
    if not ActiveGearMenu or not ActiveGearMeta then
        return
    end

    ActiveGearBindEntry = SourceEntry
    SetEntrySelected(SourceEntry, true)
    local Meta = ActiveGearMeta
    local FlagName = Meta.Flag or Meta.Name or "Unknown"
    local BindMode = "Toggle"
    local ShowInBinds = true
    local BindValue = (Meta.Info and Meta.Info.Type == "Boolean") and false or Menu.Flags[FlagName]

    ActiveGearBindMenu = Create("Frame", {
        Parent = ScreenGui,
        Active = true,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(176, 148),
        BackgroundColor3 = Color3.fromRGB(11, 13, 22),
        BorderSizePixel = 0,
        ZIndex = 180
    })
    Corner(ActiveGearBindMenu, 7)
    if AddPopupShadow then
        AddPopupShadow(ActiveGearBindMenu, 180)
    end
    Stroke(ActiveGearBindMenu, Border, 0.08, 1)

    local Preferred = UDim2.fromOffset(ActiveGearMenu.AbsolutePosition.X + ActiveGearMenu.AbsoluteSize.X + 8, ActiveGearMenu.AbsolutePosition.Y)
    PlacePopup(ActiveGearBindMenu, Preferred, {ActiveGearHotkeysMenu, ActiveGearMenu})
    MakePopupDraggable(ActiveGearBindMenu, 14)

    local ModeBackground = Create("Frame", {
        Parent = ActiveGearBindMenu,
        Position = UDim2.fromOffset(8, 17),
        Size = UDim2.fromOffset(160, 25),
        BackgroundColor3 = Color3.fromRGB(16, 18, 29),
        BorderSizePixel = 0,
        ZIndex = 181
    })
    Corner(ModeBackground, 5)

    local ToggleButton = Create("TextButton", {
        Parent = ModeBackground,
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.fromOffset(78, 21),
        BackgroundColor3 = Accent,
        BackgroundTransparency = 0.10,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.BuilderSansMedium,
        Text = "Toggle",
        TextColor3 = PrimaryText,
        TextSize = 10,
        ZIndex = 182
    })
    Corner(ToggleButton, 4)

    local HoldButton = Create("TextButton", {
        Parent = ModeBackground,
        Position = UDim2.fromOffset(81, 2),
        Size = UDim2.fromOffset(77, 21),
        BackgroundColor3 = Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.BuilderSansMedium,
        Text = "Hold",
        TextColor3 = MutedText,
        TextSize = 10,
        ZIndex = 182
    })
    Corner(HoldButton, 4)

    local Capture = Create("TextButton", {
        Parent = ActiveGearBindMenu,
        Position = UDim2.fromOffset(8, 48),
        Size = UDim2.fromOffset(160, 25),
        BackgroundColor3 = Color3.fromRGB(16, 18, 29),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.BuilderSansMedium,
        Text = "Click to bind",
        TextColor3 = PrimaryText,
        TextSize = 10,
        ZIndex = 181
    })
    Corner(Capture, 5)
    local CaptureStroke = Stroke(Capture, Border, 0.28, 1)

    Create("TextLabel", {
        Parent = ActiveGearBindMenu,
        Position = UDim2.fromOffset(10, 80),
        Size = UDim2.fromOffset(62, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = "Value",
        TextColor3 = DisabledText,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 181
    })

    CreateValueControl(ActiveGearBindMenu, Meta, BindValue, function(Value)
        BindValue = Value
    end)

    Create("Frame", {
        Parent = ActiveGearBindMenu,
        Position = UDim2.fromOffset(8, 113),
        Size = UDim2.fromOffset(160, 1),
        BackgroundColor3 = Border,
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0,
        ZIndex = 181
    })

    Create("TextLabel", {
        Parent = ActiveGearBindMenu,
        Position = UDim2.fromOffset(10, 119),
        Size = UDim2.fromOffset(110, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = "Show in binds",
        TextColor3 = DisabledText,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 181
    })

    local ShowButton = Create("TextButton", {
        Parent = ActiveGearBindMenu,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 121),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Accent,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 182
    })
    Corner(ShowButton, 3)
    local ShowStroke = Stroke(ShowButton, Accent, 0, 1)
    local ShowCheck = Icon(ShowButton, "Check", UDim2.fromOffset(9, 9), UDim2.fromScale(0.5, 0.5), Color3.fromRGB(13, 15, 23), 183)

    local function RefreshMode()
        ToggleButton.BackgroundTransparency = BindMode == "Toggle" and 0.10 or 1
        ToggleButton.TextColor3 = BindMode == "Toggle" and PrimaryText or MutedText
        HoldButton.BackgroundTransparency = BindMode == "Hold" and 0.10 or 1
        HoldButton.TextColor3 = BindMode == "Hold" and PrimaryText or MutedText
    end

    Bind(ToggleButton.MouseButton1Click:Connect(function()
        BindMode = "Toggle"
        RefreshMode()
    end))
    Bind(HoldButton.MouseButton1Click:Connect(function()
        BindMode = "Hold"
        RefreshMode()
    end))
    Bind(ShowButton.MouseButton1Click:Connect(function()
        ShowInBinds = not ShowInBinds
        ShowCheck.Visible = ShowInBinds
        ShowButton.BackgroundColor3 = ShowInBinds and Accent or SurfaceAlt
        ShowStroke.Color = ShowInBinds and Accent or Border
    end))

    Bind(Capture.MouseButton1Click:Connect(function()
        Capture.Text = "Press a key..."
        CaptureStroke.Color = Accent
        CaptureStroke.Transparency = 0
        PendingBindCapture = {
            Meta = Meta,
            Mode = function()
                return BindMode
            end,
            ShowInBinds = function()
                return ShowInBinds
            end,
            Value = function()
                return BindValue
            end,
            SetText = function(TextValue)
                if Capture.Parent then
                    Capture.Text = TextValue
                    CaptureStroke.Color = Border
                    CaptureStroke.Transparency = 0.28
                end
            end
        }
    end))
end

OpenGearMenu = function(Button, GearIcon, Meta)
    if ActiveGearButton == Button then
        CloseGearMenus()
        return
    end

    ClosePopup()
    CloseGearMenus()
    ActiveGearButton = Button
    ActiveGearButtonIcon = GearIcon
    ActiveGearMeta = Meta
    SetGearIconColor(GearIcon, PrimaryText)

    ActiveGearMenu = Create("Frame", {
        Parent = ScreenGui,
        Active = true,
        Position = UDim2.fromOffset(Button.AbsolutePosition.X - 8, Button.AbsolutePosition.Y + Button.AbsoluteSize.Y + 4),
        Size = UDim2.fromOffset(142, 106),
        BackgroundColor3 = Color3.fromRGB(11, 13, 22),
        BorderSizePixel = 0,
        ZIndex = 160
    })
    Corner(ActiveGearMenu, 7)
    if AddPopupShadow then
        AddPopupShadow(ActiveGearMenu, 160)
    end
    Stroke(ActiveGearMenu, Border, 0.08, 1)
    ActiveGearMenu.Position = type(ClampPopupPosition) == "function" and ClampPopupPosition(ActiveGearMenu, ActiveGearMenu.Position) or ActiveGearMenu.Position
    MakePopupDraggable(ActiveGearMenu, 14)

    local BindEntry = CreateMenuEntry(ActiveGearMenu, 16, "New bind", "Bind", PrimaryText, true)
    local HotkeysEntry = CreateMenuEntry(ActiveGearMenu, 46, "Hotkeys", "Hotkeys", MutedText, true)
    local ResetEntry = CreateMenuEntry(ActiveGearMenu, 76, "Reset", "Reset", Danger, false)

    ActiveGearBindEntry = BindEntry
    ActiveGearHotkeysEntry = HotkeysEntry

    Bind(BindEntry.MouseButton1Click:Connect(function()
        OpenGearBindMenu(BindEntry)
    end))
    Bind(HotkeysEntry.MouseButton1Click:Connect(function()
        OpenHotkeysMenu(HotkeysEntry)
    end))
    Bind(ResetEntry.MouseButton1Click:Connect(function()
        SavedPositions.ControlBinds = SavedPositions.ControlBinds or {}
        SavedPositions.ControlBinds[tostring(Meta.Flag or Meta.Name or "Unknown")] = {}
        SavePositions()
        if ActiveGearHotkeysMenu then
            ActiveGearHotkeysMenu:Destroy()
            ActiveGearHotkeysMenu = nil
            SetEntrySelected(HotkeysEntry, false)
        end
    end))
end

Menu.BindSystem.GetControlBinds = GetControlBinds
Menu.BindSystem.ApplyFlagValue = ApplyFlagValue
Menu.BindSystem.IsModifierKey = IsModifierKey
Menu.BindSystem.ReadModifiers = ReadModifiers
Menu.BindSystem.BuildBindDisplay = BuildBindDisplay
Menu.BindSystem.GetInputIdentity = GetInputIdentity
Menu.BindSystem.BindMatchesInput = BindMatchesInput
end

local function CreateDropdown(Section, Name, Values, Default, Flag, Options)
    Options = Options or {}
    local Row = CreateRow(Section.Body, 28)

    Create("TextLabel", {
        Parent = Row,
        Size = UDim2.new(0.54, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = Name,
        TextColor3 = Options.Disabled and DisabledText or PrimaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    })

    if Options.Gear then
        CreateGear(Row, -124, 13, Name, Flag, {Type = "Dropdown", Values = Values})
    end

    local Current = Default
    local IsOpened = false
    Menu.Flags[Flag] = Current

    local Button = Create("TextButton", {
        Parent = Row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(94, 24),
        BackgroundColor3 = Color3.fromRGB(15, 17, 28),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 9
    })
    Corner(Button, 6)
    local ButtonStroke = Stroke(Button, Border, 0.08, 1)

    local Divider = Create("Frame", {
        Parent = Button,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -22, 0.5, 0),
        Size = UDim2.fromOffset(1, 12),
        BackgroundColor3 = Border,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        ZIndex = 10
    })
    Corner(Divider, 100)

    local ValueLabel = Create("TextLabel", {
        Parent = Button,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -30, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = tostring(Default),
        TextColor3 = PrimaryText,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local Arrow = Icon(Button, "Chevron", UDim2.fromOffset(8, 8), UDim2.new(1, -11, 0.5, 0), MutedText, 10)
    Arrow.Rotation = 0

    local function RefreshClosedState(Hovered)
        if IsOpened then
            Button.BackgroundColor3 = Color3.fromRGB(17, 20, 32)
            ButtonStroke.Color = Accent
            Divider.BackgroundTransparency = 0.15
            Arrow.ImageColor3 = PrimaryText
        else
            Button.BackgroundColor3 = Hovered and Color3.fromRGB(17, 20, 32) or Color3.fromRGB(15, 17, 28)
            ButtonStroke.Color = Hovered and Color3.fromRGB(40, 46, 68) or Border
            Divider.BackgroundTransparency = Hovered and 0.25 or 0.45
            Arrow.ImageColor3 = Hovered and PrimaryText or MutedText
        end
    end

    local function Set(Value)
        Current = Value
        Menu.Flags[Flag] = Value
        ValueLabel.Text = tostring(Value)
        ClosePopup()
        ButtonStroke.Color = Accent
        task.delay(0.10 / math.max(AnimationFactor, 0.05), function()
            if ButtonStroke.Parent and not IsOpened then
                ButtonStroke.Color = Border
            end
        end)
        if type(Options.Callback) == "function" then
            task.spawn(Options.Callback, Value)
        end
    end

    Menu.Setters[Flag] = Set

    Bind(Button.MouseEnter:Connect(function()
        Tween(Button, 0.12, {BackgroundColor3 = Color3.fromRGB(17, 20, 32)})
        Tween(ButtonStroke, 0.12, {Color = IsOpened and Accent or Color3.fromRGB(40, 46, 68)})
        Tween(Divider, 0.12, {BackgroundTransparency = IsOpened and 0.15 or 0.25})
        Tween(Arrow, 0.12, {ImageColor3 = PrimaryText})
    end))
    Bind(Button.MouseLeave:Connect(function()
        if not IsOpened then
            Tween(Button, 0.12, {BackgroundColor3 = Color3.fromRGB(15, 17, 28)})
            Tween(ButtonStroke, 0.12, {Color = Border})
            Tween(Divider, 0.12, {BackgroundTransparency = 0.45})
            Tween(Arrow, 0.12, {ImageColor3 = MutedText})
        end
    end))

    Bind(Button.MouseButton1Click:Connect(function()
        if CloseGearMenus then
            CloseGearMenus()
        end
        if ActivePopup then
            ClosePopup()
            return
        end

        local Width = 108
        local PopupHeight = (#Values * 24) + 12
        ActivePopup = Create("Frame", {
            Parent = ScreenGui,
        Active = true,
            Position = UDim2.fromOffset(Button.AbsolutePosition.X + Button.AbsoluteSize.X - Width, Button.AbsolutePosition.Y + Button.AbsoluteSize.Y + 6),
            Size = UDim2.fromOffset(Width, PopupHeight),
            BackgroundColor3 = Color3.fromRGB(12, 14, 24),
            BorderSizePixel = 0,
            ZIndex = 100
        })
        Corner(ActivePopup, 7)
        Stroke(ActivePopup, Border, 0.05, 1)
        Menu:AddSoftGlow(ActivePopup, 100, 7, 0.80, true)
        ActivePopup.Position = type(ClampPopupPosition) == "function" and ClampPopupPosition(ActivePopup, ActivePopup.Position) or ActivePopup.Position

        Create("UIPadding", {
            Parent = ActivePopup,
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6)
        })

        Create("UIListLayout", {
            Parent = ActivePopup,
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        IsOpened = true
        Tween(Arrow, 0.12, {Rotation = 180, ImageColor3 = PrimaryText})
        Tween(ButtonStroke, 0.12, {Color = Accent})
        Tween(Divider, 0.12, {BackgroundTransparency = 0.15})
        Tween(Button, 0.12, {BackgroundColor3 = Color3.fromRGB(17, 20, 32)})

        ActivePopupCleanup = function()
            IsOpened = false
            Tween(Arrow, 0.12, {Rotation = 0, ImageColor3 = MutedText})
            Tween(ButtonStroke, 0.12, {Color = Border})
            Tween(Divider, 0.12, {BackgroundTransparency = 0.45})
            Tween(Button, 0.12, {BackgroundColor3 = Color3.fromRGB(15, 17, 28)})
        end

        for _, Value in ipairs(Values) do
            local Selected = Value == Current
            local Option = Create("TextButton", {
                Parent = ActivePopup,
                Size = UDim2.new(1, 0, 0, 21),
                BackgroundColor3 = Selected and Color3.fromRGB(20, 23, 35) or Color3.fromRGB(12, 14, 24),
                BackgroundTransparency = Selected and 0 or 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                ZIndex = 101
            })
            Corner(Option, 5)

            local Label = Create("TextLabel", {
                Parent = Option,
                Position = UDim2.fromOffset(9, 0),
                Size = UDim2.new(1, -24, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.BuilderSansMedium,
                Text = tostring(Value),
                TextColor3 = Selected and PrimaryText or PrimaryText,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 102
            })

            if Selected then
                local Dot = Create("Frame", {
                    Parent = Option,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(5, 5),
                    BackgroundColor3 = Accent,
                    BorderSizePixel = 0,
                    ZIndex = 102
                })
                Corner(Dot, 100)
            end

            Bind(Option.MouseEnter:Connect(function()
                if not Selected then
                    Tween(Option, 0.10, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(18, 21, 32)})
                    Tween(Label, 0.10, {TextColor3 = PrimaryText})
                end
            end))
            Bind(Option.MouseLeave:Connect(function()
                if not Selected then
                    Tween(Option, 0.10, {BackgroundTransparency = 1, BackgroundColor3 = Color3.fromRGB(12, 14, 24)})
                    Tween(Label, 0.10, {TextColor3 = PrimaryText})
                end
            end))
            Bind(Option.MouseButton1Click:Connect(function()
                Set(Value)
            end))
        end
    end))

    RegisterControl(Section, Row, Name)
    return {
        Set = Set,
        Get = function()
            return Current
        end
    }
end

local AccentUpdateTargets = {}

local function RegisterAccentTarget(Callback)
    table.insert(AccentUpdateTargets, Callback)
end

RegisterAccentTarget(function()
    UpdateSettingsButtonAppearance(SearchSettingsOpened, true)
end)

local function UpdateAccentColor(NewColor)
    local OldColor = Accent
    Accent = NewColor

    for _, Descendant in ipairs(Main:GetDescendants()) do
        pcall(function()
            if Descendant:IsA("Frame") or Descendant:IsA("TextButton") or Descendant:IsA("TextLabel") then
                if Descendant.BackgroundColor3 == OldColor then
                    Descendant.BackgroundColor3 = NewColor
                end
                if Descendant.TextColor3 == OldColor then
                    Descendant.TextColor3 = NewColor
                end
            elseif Descendant:IsA("ImageLabel") or Descendant:IsA("ImageButton") then
                if Descendant.ImageColor3 == OldColor then
                    Descendant.ImageColor3 = NewColor
                end
            elseif Descendant:IsA("UIStroke") then
                if Descendant.Color == OldColor then
                    Descendant.Color = NewColor
                end
            end
        end)
    end

    for _, Callback in ipairs(AccentUpdateTargets) do
        pcall(Callback, NewColor)
    end
end

local SettingsOverlay = Create("Frame", {
    Parent = ScreenGui,
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.62,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 25
})

local SettingsPanel = Create("Frame", {
    Parent = ScreenGui,
    Active = true,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = DecodePosition(SavedPositions.Settings, Main.Position),
    Size = UDim2.fromOffset(348, 622),
    BackgroundColor3 = Color3.fromRGB(11, 12, 21),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 30
})
Corner(SettingsPanel, 8)
Stroke(SettingsPanel, Border, 0.18, 1)

local SettingsPanelScale = Create("UIScale", {
    Parent = SettingsPanel,
    Scale = 0.96
})

local SettingsDragArea = Create("Frame", {
    Parent = SettingsPanel,
    Size = UDim2.new(1, 0, 0, 84),
    BackgroundTransparency = 1,
    ZIndex = 32
})

Create("TextLabel", {
    Parent = SettingsPanel,
    Position = UDim2.fromOffset(0, 22),
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSansMedium,
    Text = "Atramenta.rip",
    TextColor3 = PrimaryText,
    TextSize = 22,
    ZIndex = 31
})

local SettingsCloseButton = Create("TextButton", {
    Parent = SettingsPanel,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -14, 0, 14),
    Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = SurfaceAlt,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.BuilderSansMedium,
    Text = "",
    TextColor3 = MutedText,
    TextSize = 18,
    ZIndex = 34
})
Corner(SettingsCloseButton, 5)
Stroke(SettingsCloseButton, Border, 0.25, 1)
Icon(SettingsCloseButton, "Minus", UDim2.fromOffset(12, 12), UDim2.fromScale(0.5, 0.5), MutedText, 35)

local LocalPlayer = Players.LocalPlayer
local Watermark
local SetWatermarkHidden
local SetWatermarkScale

do
Watermark = Create("Frame", {
    Parent = ScreenGui,
    Position = DecodePosition(SavedPositions.Watermark, UDim2.fromOffset(28, 18)),
    Size = UDim2.fromOffset(340, 34),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = Color3.fromRGB(10, 11, 18),
    BorderSizePixel = 0,
    Visible = SavedPositions.HideWatermark ~= true,
    ZIndex = 210
})
Corner(Watermark, 5)
local WatermarkStroke = Stroke(Watermark, Border, 0.18, 1)

local WatermarkGlow = Create("ImageLabel", {
    Parent = ScreenGui,
    Position = Watermark.Position,
    Size = UDim2.fromOffset(358, 52),
    BackgroundTransparency = 1,
    Image = Menu.GlowAsset,
    ImageColor3 = Accent,
    ImageTransparency = 0.64,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(34, 34, 62, 62),
    ZIndex = 208
})

local WatermarkScale = Create("UIScale", {
    Parent = Watermark,
    Scale = math.clamp((tonumber(SavedPositions.WatermarkScale) or 100) / 100, 0.7, 1.4)
})

local WatermarkGlowScale = Create("UIScale", {
    Parent = WatermarkGlow,
    Scale = WatermarkScale.Scale
})

local function SyncWatermarkGlow()
    WatermarkGlow.Position = UDim2.new(
        Watermark.Position.X.Scale,
        Watermark.Position.X.Offset - 9,
        Watermark.Position.Y.Scale,
        Watermark.Position.Y.Offset - 9
    )
    WatermarkGlow.Size = UDim2.fromOffset(Watermark.AbsoluteSize.X + 18, Watermark.AbsoluteSize.Y + 18)
    WatermarkGlow.Visible = Watermark.Visible
end

Bind(Watermark:GetPropertyChangedSignal("Position"):Connect(SyncWatermarkGlow))
Bind(Watermark:GetPropertyChangedSignal("Visible"):Connect(SyncWatermarkGlow))
Bind(Watermark:GetPropertyChangedSignal("AbsoluteSize"):Connect(SyncWatermarkGlow))
RegisterAccentTarget(function(NewColor)
    WatermarkGlow.ImageColor3 = NewColor
end)

local WatermarkPadding = Create("UIPadding", {
    Parent = Watermark,
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10)
})

local WatermarkLayout = Create("UIListLayout", {
    Parent = Watermark,
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 0),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local function CreateWatermarkSeparator(Order)
    return Create("Frame", {
        Parent = Watermark,
        LayoutOrder = Order,
        Size = UDim2.fromOffset(1, 14),
        BackgroundColor3 = Border,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 212
    })
end

local UserSegment = Create("Frame", {
    Parent = Watermark,
    LayoutOrder = 1,
    Size = UDim2.fromOffset(94, 34),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 1,
    ZIndex = 211
})

Icon(UserSegment, "User", UDim2.fromOffset(13, 13), UDim2.new(0, 9, 0.5, 0), Accent, 213)
Create("UIPadding", {
    Parent = UserSegment,
    PaddingRight = UDim.new(0, 8)
})

local WatermarkName = Create("TextLabel", {
    Parent = UserSegment,
    Position = UDim2.fromOffset(24, 0),
    Size = UDim2.fromOffset(68, 34),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSans,
    Text = string.upper(LocalPlayer and LocalPlayer.Name or "PLAYER"),
    TextColor3 = PrimaryText,
    TextSize = 11,
    TextTruncate = Enum.TextTruncate.None,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 212
})

CreateWatermarkSeparator(2)

local ServerText = Create("TextLabel", {
    Parent = Watermark,
    LayoutOrder = 3,
    Size = UDim2.fromOffset(70, 34),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSans,
    Text = "SERVER",
    TextColor3 = PrimaryText,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 212
})

CreateWatermarkSeparator(4)

local FpsText = Create("TextLabel", {
    Parent = Watermark,
    LayoutOrder = 5,
    Size = UDim2.fromOffset(48, 34),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSans,
    Text = "0FPS",
    TextColor3 = PrimaryText,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 212
})

CreateWatermarkSeparator(6)

local PingText = Create("TextLabel", {
    Parent = Watermark,
    LayoutOrder = 7,
    Size = UDim2.fromOffset(54, 34),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSans,
    Text = "0PING",
    TextColor3 = PrimaryText,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 212
})

CreateWatermarkSeparator(8)

local ClockText = Create("TextLabel", {
    Parent = Watermark,
    LayoutOrder = 9,
    Size = UDim2.fromOffset(50, 34),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSans,
    Text = os.date("%I:%M%p"),
    TextColor3 = PrimaryText,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 212
})

local WatermarkDragging = false
local WatermarkDragStart
local WatermarkStartPosition

local function ClampWatermarkPosition(Position)
    local Camera = workspace.CurrentCamera
    local Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    local EffectiveSize = Watermark.AbsoluteSize
    if EffectiveSize.X <= 0 or EffectiveSize.Y <= 0 then
        EffectiveSize = Vector2.new(340 * WatermarkScale.Scale, 34 * WatermarkScale.Scale)
    end
    local X = math.clamp(Position.X.Offset, 8, math.max(8, Viewport.X - EffectiveSize.X - 8))
    local Y = math.clamp(Position.Y.Offset, 8, math.max(8, Viewport.Y - EffectiveSize.Y - 8))
    return UDim2.fromOffset(math.floor(X + 0.5), math.floor(Y + 0.5))
end

Bind(Watermark.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        WatermarkDragging = true
        WatermarkDragStart = Input.Position
        WatermarkStartPosition = Watermark.Position
    end
end))

Bind(UserInputService.InputChanged:Connect(function(Input)
    if WatermarkDragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = Input.Position - WatermarkDragStart
        Watermark.Position = ClampWatermarkPosition(UDim2.fromOffset(
            WatermarkStartPosition.X.Offset + Delta.X,
            WatermarkStartPosition.Y.Offset + Delta.Y
        ))
    end
end))

Bind(UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 and WatermarkDragging then
        WatermarkDragging = false
        SavedPositions.Watermark = EncodePosition(Watermark.Position)
        SavePositions()
    end
end))

local WatermarkFrames = 0
local WatermarkElapsed = 0
local WatermarkSecondElapsed = 0
Bind(RunService.RenderStepped:Connect(function(DeltaTime)
    WatermarkFrames += 1
    WatermarkElapsed += DeltaTime
    WatermarkSecondElapsed += DeltaTime

    if WatermarkElapsed >= 0.5 then
        local Fps = math.floor((WatermarkFrames / WatermarkElapsed) + 0.5)
        FpsText.Text = tostring(Fps) .. "FPS"
        WatermarkFrames = 0
        WatermarkElapsed = 0
    end

    if WatermarkSecondElapsed >= 1 then
        local Ping = 0
        pcall(function()
            Ping = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5)
        end)
        PingText.Text = tostring(Ping) .. "PING"
        ClockText.Text = os.date("%I:%M%p")
        WatermarkSecondElapsed = 0
    end
end))

task.spawn(function()
    local Region = "SERVER"
    if LocalPlayer then
        local Success, CountryCode = pcall(function()
            return LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
        end)
        if Success and type(CountryCode) == "string" and CountryCode ~= "" then
            Region = string.upper(CountryCode) .. " SERVER"
        end
    end
    if ServerText.Parent then
        ServerText.Text = Region
    end
end)

SetWatermarkHidden = function(Hidden)
    Hidden = Hidden and true or false
    Watermark.Visible = not Hidden
    WatermarkGlow.Visible = not Hidden
    Menu.Flags.HideWatermark = Hidden
    SavedPositions.HideWatermark = Hidden
    SavePositions()
end

SetWatermarkScale = function(Value)
    Value = math.clamp(tonumber(Value) or 100, 70, 140)
    local ScaleValue = Value / 100
    WatermarkScale.Scale = ScaleValue
    WatermarkGlowScale.Scale = ScaleValue
    Watermark.Position = ClampWatermarkPosition(Watermark.Position)
    SyncWatermarkGlow()
    Menu.Flags.WatermarkScale = Value
    SavedPositions.WatermarkScale = Value
    SavePositions()
end

SyncWatermarkGlow()
end

local ProfileAvatar = Create("ImageLabel", {
    Parent = SettingsPanel,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 66),
    Size = UDim2.fromOffset(48, 48),
    BackgroundColor3 = SurfaceAlt,
    BorderSizePixel = 0,
    Image = "",
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 31
})
Corner(ProfileAvatar, 48)
Stroke(ProfileAvatar, Border, 0.08, 1)

local ProfileName = Create("TextLabel", {
    Parent = SettingsPanel,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 120),
    Size = UDim2.fromOffset(220, 20),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSansMedium,
    Text = LocalPlayer and LocalPlayer.Name or "Player",
    TextColor3 = Accent,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 31
})

if LocalPlayer then
    task.spawn(function()
        local Success, Thumbnail = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if Success and ProfileAvatar.Parent then
            ProfileAvatar.Image = Thumbnail
        end
    end)
end

local function CreateInfoRow(Y, LabelText, ValueText)
    Create("TextLabel", {
        Parent = SettingsPanel,
        Position = UDim2.fromOffset(28, Y),
        Size = UDim2.fromOffset(110, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = LabelText,
        TextColor3 = PrimaryText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 31
    })

    Create("TextLabel", {
        Parent = SettingsPanel,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -28, 0, Y),
        Size = UDim2.fromOffset(120, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = ValueText,
        TextColor3 = Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 31
    })
end

CreateInfoRow(154, "Branch:", "Release")
CreateInfoRow(190, "Update:", "11.09.24")
CreateInfoRow(226, "Valid until:", "11.10.24")

Create("Frame", {
    Parent = SettingsPanel,
    Position = UDim2.fromOffset(28, 264),
    Size = UDim2.fromOffset(292, 1),
    BackgroundColor3 = Border,
    BorderSizePixel = 0,
    ZIndex = 31
})

local function CreatePopupRow(Height)
    return Create("Frame", {
        Parent = SettingsPanel,
        Size = UDim2.fromOffset(292, Height),
        Position = UDim2.fromOffset(28, 0),
        BackgroundTransparency = 1,
        ZIndex = 31
    })
end

local function CreatePopupCheckbox(Row, XOffset, Default)
    local Button = Create("TextButton", {
        Parent = Row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, XOffset, 0.5, 0),
        Size = UDim2.fromOffset(15, 15),
        BackgroundColor3 = Default and Accent or SurfaceAlt,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 33
    })
    Corner(Button, 3)
    local BorderStroke = Stroke(Button, Default and Accent or Border, 0, 1)
    local Check = Icon(Button, "Check", UDim2.fromOffset(10, 10), UDim2.fromScale(0.5, 0.5), Color3.fromRGB(13, 15, 23), 34)
    Check.Visible = Default
    return Button, BorderStroke, Check
end

local function CreatePopupToggle(Y, LabelText, Default, Callback)
    local Row = Create("Frame", {
        Parent = SettingsPanel,
        Position = UDim2.fromOffset(28, Y),
        Size = UDim2.fromOffset(292, 26),
        BackgroundTransparency = 1,
        ZIndex = 31
    })

    Create("TextLabel", {
        Parent = Row,
        Size = UDim2.new(1, -26, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = LabelText,
        TextColor3 = PrimaryText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 32
    })

    local Button, BorderStroke, Check = CreatePopupCheckbox(Row, 0, Default)
    local State = Default and true or false

    local function Set(Value)
        State = Value and true or false
        Check.Visible = State
        Button.BackgroundColor3 = State and Accent or SurfaceAlt
        BorderStroke.Color = State and Accent or Border
        if Callback then
            Callback(State)
        end
    end

    RegisterAccentTarget(function(NewColor)
        if State then
            Button.BackgroundColor3 = NewColor
            BorderStroke.Color = NewColor
        end
    end)

    Bind(Button.MouseButton1Click:Connect(function()
        Set(not State)
    end))

    Bind(Row.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local RelativeX = Input.Position.X - Row.AbsolutePosition.X
            if RelativeX < Row.AbsoluteSize.X - 22 then
                Set(not State)
            end
        end
    end))

    Set(State)
    return {
        Set = Set,
        Get = function()
            return State
        end
    }
end

local function CreatePopupSlider(Y, LabelText, Minimum, Maximum, Default, FormatText, Callback)
    local Row = Create("Frame", {
        Parent = SettingsPanel,
        Position = UDim2.fromOffset(28, Y),
        Size = UDim2.fromOffset(292, 58),
        BackgroundTransparency = 1,
        ZIndex = 31
    })

    Create("TextLabel", {
        Parent = Row,
        Size = UDim2.new(1, -56, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = LabelText,
        TextColor3 = PrimaryText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 32
    })

    local ValueLabel = Create("TextLabel", {
        Parent = Row,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(48, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = "",
        TextColor3 = PrimaryText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 32
    })

    local Track = Create("Frame", {
        Parent = Row,
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = Color3.fromRGB(28, 31, 45),
        BorderSizePixel = 0,
        ZIndex = 32
    })
    Corner(Track, 2)

    local Fill = Create("Frame", {
        Parent = Track,
        Size = UDim2.new((Default - Minimum) / (Maximum - Minimum), 0, 1, 0),
        BackgroundColor3 = Accent,
        BorderSizePixel = 0,
        ZIndex = 33
    })
    Corner(Fill, 2)

    local Knob = Create("Frame", {
        Parent = Track,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((Default - Minimum) / (Maximum - Minimum), 0, 0.5, 0),
        Size = UDim2.fromOffset(7, 14),
        BackgroundColor3 = Color3.fromRGB(226, 230, 246),
        BorderSizePixel = 0,
        ZIndex = 34
    })
    Corner(Knob, 2)

    local Value = Default
    local Dragging = false

    local function Set(NewValue)
        NewValue = math.clamp(NewValue, Minimum, Maximum)
        if Maximum <= 2 then
            NewValue = math.floor(NewValue * 100 + 0.5) / 100
        else
            NewValue = math.floor(NewValue + 0.5)
        end
        Value = NewValue
        local Alpha = (Value - Minimum) / (Maximum - Minimum)
        SmoothSlider(Fill, Knob, Alpha, 0.12)
        ValueLabel.Text = FormatText and FormatText(Value) or tostring(Value)
        if Callback then
            Callback(Value)
        end
    end

    RegisterAccentTarget(function(NewColor)
        Fill.BackgroundColor3 = NewColor
    end)

    local function Update(Input)
        local Alpha = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Set(Minimum + (Maximum - Minimum) * Alpha)
    end

    Bind(Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Update(Input)
        end
    end))

    Bind(UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(Input)
        end
    end))

    Bind(UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end))

    Set(Default)
    return {
        Set = Set,
        Get = function()
            return Value
        end
    }
end

local ColorRow = Create("Frame", {
    Parent = SettingsPanel,
    Position = UDim2.fromOffset(28, 576),
    Size = UDim2.fromOffset(292, 26),
    BackgroundTransparency = 1,
    ZIndex = 31
})

Create("TextLabel", {
    Parent = ColorRow,
    Size = UDim2.new(1, -40, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.BuilderSans,
    Text = "Accent color",
    TextColor3 = PrimaryText,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 32
})

local AccentPreviewButton = Create("TextButton", {
    Parent = ColorRow,
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -1, 0.5, 0),
    Size = UDim2.fromOffset(13, 13),
    BackgroundColor3 = Accent,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    ZIndex = 34
})
Corner(AccentPreviewButton, 100)
local AccentPreviewStroke = Stroke(AccentPreviewButton, Color3.fromRGB(232, 238, 255), 0.16, 1)
local AccentPreviewGlow = Menu:AddSoftGlow(AccentPreviewButton, 34, 8, 0.20, false)

RegisterAccentTarget(function(NewColor)
    AccentPreviewButton.BackgroundColor3 = NewColor
    if AccentPreviewGlow then
        AccentPreviewGlow.ImageColor3 = NewColor
    end
end)

local ColorPickerContainer = Create("Frame", {
    Parent = ScreenGui,
    Active = true,
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.fromOffset(174, 222),
    BackgroundColor3 = Color3.fromRGB(12, 14, 23),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 120
})
Corner(ColorPickerContainer, 7)
Stroke(ColorPickerContainer, Border, 0.08, 1)

local ColorPickerDragArea = Create("Frame", {
    Parent = ColorPickerContainer,
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundTransparency = 1,
    ZIndex = 130
})

local ColorSquare = Create("Frame", {
    Parent = ColorPickerContainer,
    Position = UDim2.fromOffset(10, 10),
    Size = UDim2.fromOffset(154, 96),
    BackgroundColor3 = Accent,
    BorderSizePixel = 0,
    ZIndex = 121
})
Corner(ColorSquare, 4)
Stroke(ColorSquare, Color3.fromRGB(35, 39, 54), 0.1, 1)

local WhiteOverlay = Create("Frame", {
    Parent = ColorSquare,
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 122
})
Corner(WhiteOverlay, 4)
Create("UIGradient", {
    Parent = WhiteOverlay,
    Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
})

local BlackOverlay = Create("Frame", {
    Parent = ColorSquare,
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BorderSizePixel = 0,
    ZIndex = 123
})
Corner(BlackOverlay, 4)
Create("UIGradient", {
    Parent = BlackOverlay,
    Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }),
    Rotation = 90
})

local ColorCursor = Create("Frame", {
    Parent = ColorSquare,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(1, 0),
    Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 124
})
Corner(ColorCursor, 10)
Stroke(ColorCursor, Color3.new(0, 0, 0), 0.12, 1)

local HueBar = Create("Frame", {
    Parent = ColorPickerContainer,
    Position = UDim2.fromOffset(10, 114),
    Size = UDim2.fromOffset(154, 8),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 121
})
Corner(HueBar, 4)
Create("UIGradient", {
    Parent = HueBar,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
    })
})

local HueKnob = Create("Frame", {
    Parent = HueBar,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0, 0.5),
    Size = UDim2.fromOffset(8, 12),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 122
})
Corner(HueKnob, 3)
Stroke(HueKnob, Color3.new(0, 0, 0), 0.2, 1)

local AlphaBar = Create("Frame", {
    Parent = ColorPickerContainer,
    Position = UDim2.fromOffset(10, 130),
    Size = UDim2.fromOffset(154, 8),
    BackgroundColor3 = Color3.fromRGB(43, 47, 61),
    BorderSizePixel = 0,
    ZIndex = 121
})
Corner(AlphaBar, 4)

local AlphaFill = Create("Frame", {
    Parent = AlphaBar,
    Size = UDim2.fromScale(AccentAlpha, 1),
    BackgroundColor3 = Accent,
    BorderSizePixel = 0,
    ZIndex = 122
})
Corner(AlphaFill, 4)

local AlphaKnob = Create("Frame", {
    Parent = AlphaBar,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(AccentAlpha, 0.5),
    Size = UDim2.fromOffset(8, 12),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 123
})
Corner(AlphaKnob, 3)
Stroke(AlphaKnob, Color3.new(0, 0, 0), 0.2, 1)

local HexBox = Create("TextBox", {
    Parent = ColorPickerContainer,
    Position = UDim2.fromOffset(10, 148),
    Size = UDim2.fromOffset(124, 28),
    BackgroundColor3 = SurfaceAlt,
    BorderSizePixel = 0,
    Font = Enum.Font.BuilderSansMedium,
    PlaceholderText = "#7ACAC2FF",
    Text = "",
    TextColor3 = PrimaryText,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 121
})
Corner(HexBox, 4)
Stroke(HexBox, Border, 0.05, 1)
Create("UIPadding", {
    Parent = HexBox,
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 6)
})

local function SetTextInputsEnabled(State)
    pcall(function()
        if not State then
            SearchBox:ReleaseFocus()
        end
        SearchBox.TextEditable = State
    end)
    pcall(function()
        if not State then
            HexBox:ReleaseFocus()
        end
        HexBox.TextEditable = State
    end)
end

local ApplyHex = Create("TextButton", {
    Parent = ColorPickerContainer,
    Position = UDim2.fromOffset(138, 148),
    Size = UDim2.fromOffset(26, 28),
    BackgroundColor3 = SurfaceAlt,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    ZIndex = 121
})
Corner(ApplyHex, 4)
Stroke(ApplyHex, Border, 0.05, 1)

local PencilBody = Create("Frame", {
    Parent = ApplyHex,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.48, 0.48),
    Size = UDim2.fromOffset(3, 13),
    Rotation = 42,
    BackgroundColor3 = PrimaryText,
    BorderSizePixel = 0,
    ZIndex = 122
})
Corner(PencilBody, 2)
Create("Frame", {
    Parent = ApplyHex,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.68, 0.69),
    Size = UDim2.fromOffset(3, 3),
    Rotation = 42,
    BackgroundColor3 = MutedText,
    BorderSizePixel = 0,
    ZIndex = 122
})

local ThemeRow = Create("Frame", {
    Parent = ColorPickerContainer,
    Position = UDim2.fromOffset(10, 184),
    Size = UDim2.fromOffset(154, 28),
    BackgroundTransparency = 1,
    ZIndex = 121
})

local AddThemeButton = Create("TextButton", {
    Parent = ThemeRow,
    Position = UDim2.fromOffset(0, 2),
    Size = UDim2.fromOffset(20, 20),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    ZIndex = 122
})
local PlusHorizontal = Create("Frame", {
    Parent = AddThemeButton,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(9, 1),
    BackgroundColor3 = PrimaryText,
    BorderSizePixel = 0,
    ZIndex = 123
})
local PlusVertical = Create("Frame", {
    Parent = AddThemeButton,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(1, 9),
    BackgroundColor3 = PrimaryText,
    BorderSizePixel = 0,
    ZIndex = 123
})

local ThemeDots = Create("Frame", {
    Parent = ThemeRow,
    Position = UDim2.fromOffset(24, 0),
    Size = UDim2.fromOffset(130, 24),
    BackgroundTransparency = 1,
    ZIndex = 122
})
Create("UIListLayout", {
    Parent = ThemeDots,
    FillDirection = Enum.FillDirection.Horizontal,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local ThemeButtons = {}

local function ClearThemeButtons()
    for _, Button in ipairs(ThemeButtons) do
        Button:Destroy()
    end
    table.clear(ThemeButtons)
end

local function ColorToThemeHex(Color)
    return string.format("#%02X%02X%02X", math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5))
end

local function ThemeHexToColor(Value)
    local Hex = tostring(Value):gsub("#", "")
    if #Hex ~= 6 then
        return nil
    end
    local Red = tonumber(Hex:sub(1, 2), 16)
    local Green = tonumber(Hex:sub(3, 4), 16)
    local Blue = tonumber(Hex:sub(5, 6), 16)
    if not Red or not Green or not Blue then
        return nil
    end
    return Color3.fromRGB(Red, Green, Blue)
end

local SetPickerColor

local function RefreshThemeButtons()
    ClearThemeButtons()
    for Index, Hex in ipairs(ThemeColors) do
        local Color = ThemeHexToColor(Hex)
        if Color then
            local Button = Create("TextButton", {
                Parent = ThemeDots,
                LayoutOrder = Index,
                Size = UDim2.fromOffset(12, 12),
                BackgroundColor3 = Color,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                ZIndex = 123
            })
            Corner(Button, 12)
            Stroke(Button, Color3.new(1, 1, 1), 0.82, 1)
            table.insert(ThemeButtons, Button)
            Bind(Button.MouseButton1Click:Connect(function()
                if SetPickerColor then
                    SetPickerColor(Color)
                    SavedPositions.AccentHex = ColorToThemeHex(Color)
                    SavedPositions.AccentAlpha = AccentAlpha
                    SavePositions()
                end
            end))
            Bind(Button.MouseButton2Click:Connect(function()
                if #ThemeColors > 1 then
                    table.remove(ThemeColors, Index)
                    SavedPositions.ThemeColors = ThemeColors
                    SavePositions()
                    RefreshThemeButtons()
                end
            end))
        end
    end
end

RefreshThemeButtons()

local PickerOpen = false
local SettingsOpen = false
local HueValue, SaturationValue, BrightnessValue = Color3.toHSV(Accent)
local PickerDragging = false
local HueDragging = false
local AlphaDragging = false

local function ColorToHex(Color)
    return string.format("#%02X%02X%02X%02X", math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5), math.floor(AccentAlpha * 255 + 0.5))
end

local function HexToColor(Value)
    local Sanitized = Value:gsub("#", "")
    if #Sanitized ~= 6 and #Sanitized ~= 8 then
        return nil
    end
    local Red = tonumber(Sanitized:sub(1, 2), 16)
    local Green = tonumber(Sanitized:sub(3, 4), 16)
    local Blue = tonumber(Sanitized:sub(5, 6), 16)
    local Alpha = #Sanitized == 8 and tonumber(Sanitized:sub(7, 8), 16) or 255
    if not Red or not Green or not Blue or not Alpha then
        return nil
    end
    return Color3.fromRGB(Red, Green, Blue), Alpha / 255
end

local function RefreshPicker()
    local Color = Color3.fromHSV(HueValue, SaturationValue, BrightnessValue)
    ColorSquare.BackgroundColor3 = Color3.fromHSV(HueValue, 1, 1)
    ColorCursor.Position = UDim2.fromScale(SaturationValue, 1 - BrightnessValue)
    HueKnob.Position = UDim2.fromScale(HueValue, 0.5)
    AlphaFill.Size = UDim2.fromScale(AccentAlpha, 1)
    AlphaFill.BackgroundColor3 = Color
    AlphaKnob.Position = UDim2.fromScale(AccentAlpha, 0.5)
    AccentPreviewButton.BackgroundTransparency = 1 - AccentAlpha
    if AccentPreviewGlow then
        AccentPreviewGlow.ImageTransparency = (PickerOpen and 0.16 or (0.28 - (AccentAlpha * 0.10)))
    end
    AccentPreviewStroke.Transparency = PickerOpen and 0.08 or 0.16
    Menu.Flags.AccentAlpha = AccentAlpha
    HexBox.Text = ColorToHex(Color)
    UpdateAccentColor(Color)
end

SetPickerColor = function(Color, Alpha)
    HueValue, SaturationValue, BrightnessValue = Color3.toHSV(Color)
    if Alpha ~= nil then
        AccentAlpha = math.clamp(Alpha, 0, 1)
    end
    RefreshPicker()
end

local function PositionColorPicker(UseSavedPosition)
    local Camera = workspace.CurrentCamera
    local Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    local PickerSize = ColorPickerContainer.AbsoluteSize
    if PickerSize.X <= 0 or PickerSize.Y <= 0 then
        PickerSize = Vector2.new(174, 222)
    end

    local SwatchPosition = AccentPreviewButton.AbsolutePosition
    local SwatchSize = AccentPreviewButton.AbsoluteSize
    local Gap = 8

    local DefaultX = SwatchPosition.X - PickerSize.X - Gap
    local DefaultY = SwatchPosition.Y + (SwatchSize.Y - PickerSize.Y) * 0.5

    if DefaultX < 10 then
        DefaultX = SwatchPosition.X + SwatchSize.X + Gap
    end

    local X = DefaultX
    local Y = DefaultY

    if UseSavedPosition and SavedPositions.ColorPickerPinned and type(SavedPositions.ColorPickerOffsetX) == "number" and type(SavedPositions.ColorPickerOffsetY) == "number" then
        local CandidateX = SettingsPanel.AbsolutePosition.X + SavedPositions.ColorPickerOffsetX
        local CandidateY = SettingsPanel.AbsolutePosition.Y + SavedPositions.ColorPickerOffsetY
        local OffsetX = math.abs(CandidateX - DefaultX)
        local OffsetY = math.abs(CandidateY - DefaultY)
        if OffsetX <= 260 and OffsetY <= 260 then
            X = CandidateX
            Y = CandidateY
        end
    end

    X = math.clamp(X, 10, math.max(10, Viewport.X - PickerSize.X - 10))
    Y = math.clamp(Y, 10, math.max(10, Viewport.Y - PickerSize.Y - 10))

    ColorPickerContainer.Position = UDim2.fromOffset(math.floor(X + 0.5), math.floor(Y + 0.5))
end

local function SetPickerOpen(State)
    PickerOpen = State
    if State then
        if AccentPreviewGlow then
            Tween(AccentPreviewGlow, 0.12, {ImageTransparency = 0.16})
        end
        ColorPickerContainer.Visible = true
        task.defer(function()
            if PickerOpen and ColorPickerContainer.Parent then
                PositionColorPicker(true)
            end
        end)
    else
        if AccentPreviewGlow then
            Tween(AccentPreviewGlow, 0.12, {ImageTransparency = 0.28 - (AccentAlpha * 0.10)})
        end
        ColorPickerContainer.Visible = false
        SavedPositions.AccentHex = ColorToThemeHex(Color3.fromHSV(HueValue, SaturationValue, BrightnessValue))
        SavedPositions.AccentAlpha = AccentAlpha
        SavedPositions.ThemeColors = ThemeColors
        SavedPositions.ColorPickerOffsetX = ColorPickerContainer.AbsolutePosition.X - SettingsPanel.AbsolutePosition.X
        SavedPositions.ColorPickerOffsetY = ColorPickerContainer.AbsolutePosition.Y - SettingsPanel.AbsolutePosition.Y
        SavePositions()
    end
end

local function SetSettingsOpen(State)
    SettingsOpen = State
    UpdateSettingsButtonAppearance(State)
    SettingsOverlay.Visible = false
    SettingsPanel.Visible = State
    if State then
        SettingsPanel.Position = DecodePosition(SavedPositions.Settings, Main.Position)
        SettingsPanelScale.Scale = 0.96
        SettingsPanel.BackgroundTransparency = 0.08
        Tween(SettingsPanelScale, 0.14, {Scale = 1})
        Tween(SettingsPanel, 0.14, {BackgroundTransparency = 0})
    else
        SavedPositions.Settings = EncodePosition(SettingsPanel.Position)
        SavePositions()
        Tween(SettingsPanelScale, 0.1, {Scale = 0.96})
        Tween(SettingsPanel, 0.1, {BackgroundTransparency = 0.08})
        task.delay(0.1, function()
            if not SettingsOpen then
                SettingsPanel.Visible = false
                SetPickerOpen(false)
            end
        end)
    end
end

Bind(SettingsCloseButton.MouseButton1Click:Connect(function()
    SetSettingsOpen(false)
end))

Bind(AccentPreviewButton.MouseButton1Click:Connect(function()
    SetPickerOpen(not PickerOpen)
end))

Bind(AccentPreviewButton.MouseEnter:Connect(function()
    Tween(AccentPreviewStroke, 0.12, {Transparency = 0.08})
    if not PickerOpen then
        if AccentPreviewGlow then
            Tween(AccentPreviewGlow, 0.12, {ImageTransparency = 0.20})
        end
    end
end))

Bind(AccentPreviewButton.MouseLeave:Connect(function()
    Tween(AccentPreviewStroke, 0.12, {Transparency = PickerOpen and 0.08 or 0.16})
    if not PickerOpen then
        if AccentPreviewGlow then
            Tween(AccentPreviewGlow, 0.12, {ImageTransparency = 0.28 - (AccentAlpha * 0.10)})
        end
    end
end))

local function UpdateSquare(Input)
    local X = math.clamp((Input.Position.X - ColorSquare.AbsolutePosition.X) / ColorSquare.AbsoluteSize.X, 0, 1)
    local Y = math.clamp((Input.Position.Y - ColorSquare.AbsolutePosition.Y) / ColorSquare.AbsoluteSize.Y, 0, 1)
    SaturationValue = X
    BrightnessValue = 1 - Y
    RefreshPicker()
end

local function UpdateHue(Input)
    local X = math.clamp((Input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
    HueValue = X
    RefreshPicker()
end

local function UpdateAlpha(Input)
    AccentAlpha = math.clamp((Input.Position.X - AlphaBar.AbsolutePosition.X) / AlphaBar.AbsoluteSize.X, 0, 1)
    RefreshPicker()
end

Bind(ColorSquare.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        PickerDragging = true
        UpdateSquare(Input)
    end
end))

Bind(HueBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        HueDragging = true
        UpdateHue(Input)
    end
end))

Bind(AlphaBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        AlphaDragging = true
        UpdateAlpha(Input)
    end
end))

Bind(UserInputService.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseMovement then
        if PickerDragging then
            UpdateSquare(Input)
        end
        if HueDragging then
            UpdateHue(Input)
        end
        if AlphaDragging then
            UpdateAlpha(Input)
        end
    end
end))

Bind(UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        PickerDragging = false
        HueDragging = false
        AlphaDragging = false
        SavedPositions.AccentHex = ColorToThemeHex(Color3.fromHSV(HueValue, SaturationValue, BrightnessValue))
        SavedPositions.AccentAlpha = AccentAlpha
        SavePositions()
    end
end))

Bind(ApplyHex.MouseButton1Click:Connect(function()
    local Parsed, ParsedAlpha = HexToColor(HexBox.Text)
    if Parsed then
        SetPickerColor(Parsed, ParsedAlpha)
        SavedPositions.AccentHex = ColorToThemeHex(Parsed)
        SavedPositions.AccentAlpha = AccentAlpha
        SavePositions()
    end
end))

Bind(HexBox.FocusLost:Connect(function(EnterPressed)
    if EnterPressed then
        local Parsed, ParsedAlpha = HexToColor(HexBox.Text)
        if Parsed then
            SetPickerColor(Parsed, ParsedAlpha)
            SavedPositions.AccentHex = ColorToThemeHex(Parsed)
            SavedPositions.AccentAlpha = AccentAlpha
            SavePositions()
        else
            HexBox.Text = ColorToHex(Color3.fromHSV(HueValue, SaturationValue, BrightnessValue))
        end
    end
end))

CreatePopupToggle(280, "Auto save", true, function(Value)
    Menu.Flags.AutoSave = Value
end)

CreatePopupToggle(312, "Background dim", true, function(Value)
    Menu.Flags.BackgroundDim = Value
    Overlay.Visible = Menu.Visible and Value
end)

CreatePopupSlider(346, "Anim. speed", 0.2, 2, 1, function(Value)
    return string.format("%.1f", Value)
end, function(Value)
    AnimationFactor = math.max(Value, 0.05)
    Menu.Flags.AnimationSpeed = Value
end)

CreatePopupSlider(412, "Scale", 80, 125, 100, function(Value)
    return tostring(math.floor(Value + 0.5)) .. "%"
end, function(Value)
    BaseScaleFactor = Value / 100
    MainScale.Scale = (Menu.Flags.ViewportScale or 1) * BaseScaleFactor
    Menu.Flags.MenuScale = Value
end)


CreatePopupToggle(478, "Hide watermark", SavedPositions.HideWatermark == true, function(Value)
    SetWatermarkHidden(Value)
end)

CreatePopupSlider(510, "Watermark size", 70, 140, tonumber(SavedPositions.WatermarkScale) or 100, function(Value)
    return tostring(math.floor(Value + 0.5)) .. "%"
end, function(Value)
    SetWatermarkScale(Value)
end)

Menu.ToggleSettingsPanel = function()
    SetSettingsOpen(not SettingsOpen)
end

Bind(AddThemeButton.MouseButton1Click:Connect(function()
    local CurrentHex = ColorToThemeHex(Color3.fromHSV(HueValue, SaturationValue, BrightnessValue))
    for _, ExistingHex in ipairs(ThemeColors) do
        if string.upper(ExistingHex) == string.upper(CurrentHex) then
            return
        end
    end
    if #ThemeColors >= 7 then
        table.remove(ThemeColors, 1)
    end
    table.insert(ThemeColors, CurrentHex)
    SavedPositions.ThemeColors = ThemeColors
    SavePositions()
    RefreshThemeButtons()
end))

SetPickerColor(Accent, AccentAlpha)
SetPickerOpen(false)
local CombatPage = CreatePage("Combat")
local MiscPage = CreatePage("Misc")
local SettingsPage = CreatePage("Settings")
local VisualsPage = CreatePage("Visuals")
local PlayersPage = CreatePage("Players")
local CloudPage = CreatePage("Cloud")
local ConfigPage = CreatePage("Config")

local General = CreateSection(CombatPage, "General", "General", UDim2.fromOffset(0, 0), UDim2.fromOffset(306, 288))
CreateToggle(General, "Enable ragebot", true, "EnableRagebot", {Gear = true})
CreateToggle(General, "Silent aimbot", false, "SilentAimbot", {Disabled = true})
CreateToggle(General, "Auto revolver", true, "AutoRevolver", {Warning = true, Gear = true})
CreateToggle(General, "Anti step", true, "AntiStep")
CreateSlider(General, "Backtracking", 0, 100, 75.5, "Backtracking", {Decimals = 1, Box = true})
CreateSlider(General, "Field of view", 0, 180, 90, "FieldOfView", {Gear = true, Box = true})

local Exploits = CreateSection(CombatPage, "Exploits", "Exploits", UDim2.fromOffset(320, 0), UDim2.fromOffset(302, 288))
CreateToggle(Exploits, "Enable autofire", true, "EnableAutofire", {Warning = true, Gear = true})
CreateSlider(Exploits, "Hitchance", 0, 100, 50, "Hitchance", {Box = true})
CreateDualSlider(Exploits, "Min. damage", 0, 100, 20, 80, "MinimumDamage", "OverrideDamage")
CreateToggle(Exploits, "Hide shots", false, "HideShots", {Disabled = true})
CreateToggle(Exploits, "Double tap", true, "DoubleTap", {Gear = true})
CreateToggle(Exploits, "Teleport boost", true, "TeleportBoost")

local Accuracy = CreateSection(CombatPage, "Accuracy", "Accuracy", UDim2.fromOffset(0, 300), UDim2.fromOffset(306, 164))
CreateToggle(Accuracy, "Head safety if lethal", true, "HeadSafety")
CreateDropdown(Accuracy, "Body aimbot", {"Prefer", "Force", "Off"}, "Prefer", "BodyAimbot", {Gear = true})
CreateDropdown(Accuracy, "Safe points", {"Prefer", "Force", "Off"}, "Prefer", "SafePoints", {Gear = true, Disabled = true})

local Others = CreateSection(CombatPage, "Others", "Others", UDim2.fromOffset(320, 300), UDim2.fromOffset(302, 164))
CreateToggle(Others, "Auto stop", true, "AutoStop", {Gear = true})
CreateToggle(Others, "Conditions", true, "Conditions", {Warning = true})
CreateToggle(Others, "Auto scope", false, "AutoScope", {Disabled = true})

local function PopulateSimplePage(Page, LeftTitle, RightTitle, LeftControls, RightControls)
    local Left = CreateSection(Page, LeftTitle, LeftTitle, UDim2.fromOffset(0, 0), UDim2.fromOffset(306, 230))
    local Right = CreateSection(Page, RightTitle, RightTitle, UDim2.fromOffset(320, 0), UDim2.fromOffset(302, 230))
    for _, Definition in ipairs(LeftControls) do
        CreateToggle(Left, Definition[1], Definition[2], Definition[3], Definition[4])
    end
    for _, Definition in ipairs(RightControls) do
        CreateToggle(Right, Definition[1], Definition[2], Definition[3], Definition[4])
    end
end

PopulateSimplePage(MiscPage, "Movement", "Utility", {
    {"Bunny hop", true, "BunnyHop"},
    {"Auto strafe", true, "AutoStrafe"},
    {"Air control", true, "AirControl"},
    {"No fall damage", true, "NoFallDamage"}
}, {
    {"Auto reload", true, "AutoReload"},
    {"Third person", false, "ThirdPerson"},
    {"Infinite stamina", false, "InfiniteStamina"},
    {"Finish aura", false, "FinishAura"}
})

PopulateSimplePage(SettingsPage, "Interface", "Configuration", {
    {"Background dim", true, "BackgroundDim"},
    {"Blur effect", false, "BlurEffect"},
    {"Watermark", true, "Watermark"},
    {"Keybind list", true, "KeybindList"}
}, {
    {"Auto save", true, "AutoSave"},
    {"Cloud sync", false, "CloudSync"},
    {"Notifications", true, "Notifications"},
    {"Load default", false, "LoadDefault"}
})

PopulateSimplePage(VisualsPage, "Players", "World", {
    {"Enable ESP", true, "EnableEsp"},
    {"Bounding box", true, "BoundingBox"},
    {"Health bar", true, "HealthBar"},
    {"Weapon", true, "WeaponEsp"}
}, {
    {"Crosshair", true, "Crosshair"},
    {"Hit marker", true, "HitMarker"},
    {"Bullet tracers", false, "BulletTracers"},
    {"Night mode", false, "NightMode"}
})

PopulateSimplePage(PlayersPage, "Target", "Preview", {
    {"Target HUD", true, "TargetHud"},
    {"Snaplines", false, "Snaplines"},
    {"Resolver info", true, "ResolverInfo"}
}, {
    {"ESP preview", true, "EspPreview"},
    {"Show self", true, "ShowSelf"},
    {"Follow target", false, "FollowTarget"}
})

task.defer(function()
    local EspPreviewCard = CreateSection(PlayersPage, "EspPreviewCard", "ESP Preview", UDim2.fromOffset(0, 244), UDim2.fromOffset(626, 220))
    for _, Child in ipairs(EspPreviewCard.Body:GetChildren()) do
        if Child:IsA("UIListLayout") then
            Child:Destroy()
        end
    end

    local PreviewViewport = Create("ViewportFrame", {
        Parent = EspPreviewCard.Body,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(244, 160),
        BackgroundColor3 = Color3.fromRGB(11, 13, 22),
        BorderSizePixel = 0,
        CurrentCamera = nil,
        ZIndex = 8
    })
    Corner(PreviewViewport, 7)
    Stroke(PreviewViewport, Border, 0.08, 1)

    local PreviewGradient = Create("UIGradient", {
        Parent = PreviewViewport,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 19, 32)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 10, 18))
        }),
        Rotation = 90
    })

    local PreviewCamera = Create("Camera", {
        Parent = PreviewViewport,
        FieldOfView = 36
    })
    PreviewViewport.CurrentCamera = PreviewCamera

    local PreviewWorld = Create("WorldModel", {
        Parent = PreviewViewport
    })

    local PreviewBackGlow = Menu:AddSoftGlow(PreviewViewport, 8, 10, 0.82, true)

    local PreviewBox = Create("Frame", {
        Parent = PreviewViewport,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(82, 116),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 10
    })
    local PreviewBoxStroke = Stroke(PreviewBox, Accent, 0.12, 1)

    local PreviewHealthBack = Create("Frame", {
        Parent = PreviewViewport,
        Position = UDim2.new(0.5, -50, 0.5, -58),
        Size = UDim2.fromOffset(4, 116),
        BackgroundColor3 = Color3.fromRGB(18, 20, 31),
        BorderSizePixel = 0,
        ZIndex = 10
    })
    Corner(PreviewHealthBack, 100)

    local PreviewHealthFill = Create("Frame", {
        Parent = PreviewHealthBack,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Accent,
        BorderSizePixel = 0,
        ZIndex = 11
    })
    Corner(PreviewHealthFill, 100)

    local PreviewName = Create("TextLabel", {
        Parent = PreviewViewport,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.fromOffset(180, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = string.upper((LocalPlayer and LocalPlayer.Name) or "PLAYER"),
        TextColor3 = PrimaryText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 10
    })

    local PreviewFooter = Create("Frame", {
        Parent = PreviewViewport,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -8),
        Size = UDim2.fromOffset(180, 24),
        BackgroundColor3 = Color3.fromRGB(10, 12, 20),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = 10
    })
    Corner(PreviewFooter, 6)
    Stroke(PreviewFooter, Border, 0.18, 1)

    local PreviewWeapon = Create("TextLabel", {
        Parent = PreviewFooter,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -16, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = "NONE",
        TextColor3 = MutedText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 11
    })

    local PreviewDisabled = Create("TextLabel", {
        Parent = PreviewViewport,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(190, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = "Enable ESP preview to show the avatar.",
        TextColor3 = DisabledText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 12,
        Visible = false
    })

    local InfoPanel = Create("Frame", {
        Parent = EspPreviewCard.Body,
        Position = UDim2.fromOffset(258, 0),
        Size = UDim2.new(1, -258, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 12, 20),
        BorderSizePixel = 0,
        ZIndex = 8
    })
    Corner(InfoPanel, 7)
    Stroke(InfoPanel, Border, 0.08, 1)

    local InfoTitle = Create("TextLabel", {
        Parent = InfoPanel,
        Position = UDim2.fromOffset(14, 10),
        Size = UDim2.new(1, -28, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSansMedium,
        Text = "Live preview",
        TextColor3 = PrimaryText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9
    })

    local InfoSub = Create("TextLabel", {
        Parent = InfoPanel,
        Position = UDim2.fromOffset(14, 28),
        Size = UDim2.new(1, -28, 0, 14),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = "A cleaner full-body preview that mirrors your visual ESP options.",
        TextColor3 = MutedText,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9
    })

    local function CreateMiniTag(ParentObject, X, Y, Width, LabelText)
        local Tag = Create("Frame", {
            Parent = ParentObject,
            Position = UDim2.fromOffset(X, Y),
            Size = UDim2.fromOffset(Width, 28),
            BackgroundColor3 = Color3.fromRGB(13, 15, 24),
            BorderSizePixel = 0,
            ZIndex = 9
        })
        Corner(Tag, 6)
        Stroke(Tag, Border, 0.14, 1)
        local Dot = Create("Frame", {
            Parent = Tag,
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.fromOffset(8, 8),
            BackgroundColor3 = Accent,
            BorderSizePixel = 0,
            ZIndex = 10
        })
        Corner(Dot, 100)
        local TextLabel = Create("TextLabel", {
            Parent = Tag,
            Position = UDim2.fromOffset(24, 0),
            Size = UDim2.new(1, -32, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.BuilderSansMedium,
            Text = LabelText,
            TextColor3 = PrimaryText,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 10
        })
        return Tag, Dot, TextLabel
    end

    local TagBox, DotBox, LabelBox = CreateMiniTag(InfoPanel, 14, 58, 110, "Bounding box")
    local TagHealth, DotHealth, LabelHealth = CreateMiniTag(InfoPanel, 132, 58, 104, "Health bar")
    local TagWeapon, DotWeapon, LabelWeapon = CreateMiniTag(InfoPanel, 14, 92, 110, "Weapon")
    local TagSelf, DotSelf, LabelSelf = CreateMiniTag(InfoPanel, 132, 92, 104, "Show self")

    local PreviewStats = Create("Frame", {
        Parent = InfoPanel,
        Position = UDim2.fromOffset(14, 128),
        Size = UDim2.new(1, -28, 0, 28),
        BackgroundColor3 = Color3.fromRGB(13, 15, 24),
        BorderSizePixel = 0,
        ZIndex = 9
    })
    Corner(PreviewStats, 6)
    Stroke(PreviewStats, Border, 0.14, 1)

    local PreviewStatsLabel = Create("TextLabel", {
        Parent = PreviewStats,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = "Health 100   •   Distance 0m   •   State Visible",
        TextColor3 = MutedText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })

    local PreviewCharacter
    local PreviewRotation = 0
    local LastPreviewRefresh = 0

    local function ApplyPreviewAccent(NewColor)
        PreviewBoxStroke.Color = NewColor
        PreviewHealthFill.BackgroundColor3 = NewColor
        if PreviewBackGlow then
            PreviewBackGlow.ImageColor3 = NewColor
        end
        for _, Dot in ipairs({DotBox, DotHealth, DotWeapon, DotSelf}) do
            Dot.BackgroundColor3 = NewColor
        end
    end
    RegisterAccentTarget(ApplyPreviewAccent)

    local function ClearPreviewCharacter()
        if PreviewCharacter and PreviewCharacter.Parent then
            PreviewCharacter:Destroy()
        end
        PreviewCharacter = nil
    end

    local function BuildPreviewCharacter()
        ClearPreviewCharacter()
        local Model
        if LocalPlayer then
            local Success = pcall(function()
                Model = Players:CreateHumanoidModelFromUserId(LocalPlayer.UserId)
            end)
            if not Success or not Model then
                local Character = LocalPlayer.Character
                if Character then
                    Model = Character:Clone()
                end
            end
        end
        if not Model then
            return
        end

        for _, Descendant in ipairs(Model:GetDescendants()) do
            if Descendant:IsA("Script") or Descendant:IsA("LocalScript") or Descendant:IsA("Animator") then
                Descendant:Destroy()
            elseif Descendant:IsA("BasePart") then
                Descendant.Anchored = true
                Descendant.CanCollide = false
            end
        end

        Model.Parent = PreviewWorld
        local RootPart = Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart or Model:FindFirstChildWhichIsA("BasePart")
        if RootPart then
            Model:PivotTo(CFrame.new(0, -3.2, 0) * CFrame.Angles(0, math.rad(180), 0))
            PreviewCamera.CFrame = CFrame.new(Vector3.new(0, 1.45, 7.2), Vector3.new(0, 1.2, 0))
        end
        PreviewCharacter = Model
    end

    local function UpdatePreviewDetails()
        local Enabled = Menu.Flags.EspPreview ~= false
        PreviewViewport.Visible = true
        PreviewDisabled.Visible = not Enabled
        if not Enabled then
            ClearPreviewCharacter()
        elseif not PreviewCharacter then
            BuildPreviewCharacter()
        end

        local Character = LocalPlayer and LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
        local Health = math.floor((Humanoid and Humanoid.Health) or 100)
        local MaxHealth = math.max(1, math.floor((Humanoid and Humanoid.MaxHealth) or 100))
        local Alpha = math.clamp(Health / MaxHealth, 0, 1)
        PreviewHealthFill.Size = UDim2.fromScale(1, Alpha)
        PreviewName.Text = string.upper((LocalPlayer and LocalPlayer.Name) or "PLAYER") .. "  [" .. tostring(Health) .. "]"

        local ToolName = "NONE"
        if Character then
            local Tool = Character:FindFirstChildOfClass("Tool")
            if Tool then
                ToolName = string.upper(Tool.Name)
            end
        end
        PreviewWeapon.Text = ToolName
        PreviewStatsLabel.Text = string.format("Health %d   •   Distance 0m   •   State Visible", Health)

        local function UpdateTag(Dot, LabelObject, Value)
            Dot.BackgroundColor3 = Value and Accent or Color3.fromRGB(62, 68, 92)
            LabelObject.TextColor3 = Value and PrimaryText or MutedText
        end
        UpdateTag(DotBox, LabelBox, Menu.Flags.BoundingBox ~= false)
        UpdateTag(DotHealth, LabelHealth, Menu.Flags.HealthBar ~= false)
        UpdateTag(DotWeapon, LabelWeapon, Menu.Flags.WeaponEsp ~= false)
        UpdateTag(DotSelf, LabelSelf, Menu.Flags.ShowSelf ~= false)
    end

    if LocalPlayer then
        Bind(LocalPlayer.CharacterAdded:Connect(function()
            task.delay(0.4, function()
                BuildPreviewCharacter()
                UpdatePreviewDetails()
            end)
        end))
    end

    Bind(RunService.RenderStepped:Connect(function(DeltaTime)
        if PreviewCharacter and PreviewCharacter.Parent and Menu.Visible and PlayersPage.Visible and Menu.Flags.EspPreview ~= false then
            PreviewRotation += DeltaTime * 28
            PreviewCharacter:PivotTo(CFrame.new(0, -3.2, 0) * CFrame.Angles(0, math.rad(180 + PreviewRotation), 0))
        end
        if os.clock() - LastPreviewRefresh > 0.12 then
            LastPreviewRefresh = os.clock()
            UpdatePreviewDetails()
        end
    end))

    UpdatePreviewDetails()
end)

PopulateSimplePage(CloudPage, "Cloud", "Account", {
    {"Synchronization", false, "Synchronization"},
    {"Upload config", false, "UploadConfig"},
    {"Download config", false, "DownloadConfig"}
}, {
    {"Private mode", true, "PrivateMode"},
    {"Remember account", true, "RememberAccount"},
    {"Status notifications", true, "StatusNotifications"}
})

PopulateSimplePage(ConfigPage, "Storage", "Sharing", {
    {"Auto load", false, "AutoLoad"},
    {"Backup", true, "Backup"},
    {"Restore last", false, "RestoreLast"}
}, {
    {"Export clipboard", true, "ExportClipboard"},
    {"Import clipboard", true, "ImportClipboard"},
    {"Overwrite prompt", true, "OverwritePrompt"}
})

local CurrentPage = "Combat"
local CurrentMode = "Ragebot"

local function SelectMode(Name)
    CurrentMode = Name
    for ModeName, Button in pairs(Menu.ModeButtons) do
        local Selected = ModeName == Name
        Tween(Button, 0.14, {
            BackgroundTransparency = Selected and 0 or 1,
            BackgroundColor3 = Selected and SurfaceAlt or Surface,
            TextColor3 = Selected and PrimaryText or MutedText
        })
    end
end

local function RestorePageSections(Page, Animated)
    for _, Section in pairs(Menu.Sections) do
        if Section.Root.Parent == Page then
            local Target = Section.HomePosition or Section.Root.Position
            local SectionScale = Section.AssemblyScale

            if Animated and SectionScale then
                local StartX = Target.X.Offset > 0 and 18 or -18
                Section.Root.Position = UDim2.new(
                    Target.X.Scale,
                    Target.X.Offset + StartX,
                    Target.Y.Scale,
                    Target.Y.Offset + 8
                )
                SectionScale.Scale = 0.97
                Tween(Section.Root, 0.2, {Position = Target})
                Tween(SectionScale, 0.2, {Scale = 1})
            else
                Section.Root.Position = Target
                if SectionScale then
                    SectionScale.Scale = 1
                end
            end
        end
    end
end

local function SelectPage(Name)
    CurrentPage = Name
    ClosePopup()
    local SelectedPage = Menu.Pages[Name]
    for PageName, Page in pairs(Menu.Pages) do
        Page.Visible = PageName == Name
    end
    RestorePageSections(SelectedPage, Menu.Visible and Main.Visible)
    for ButtonName, Data in pairs(Menu.SidebarButtons) do
        local Selected = ButtonName == Name
        Tween(Data.Button, 0.14, {
            BackgroundTransparency = Selected and 0 or 1,
            BackgroundColor3 = Selected and Color3.fromRGB(28, 30, 43) or SidebarColor
        })
        Tween(Data.Marker, 0.14, {
            BackgroundTransparency = Selected and 0 or 1
        })
        if Data.Icon:IsA("ImageLabel") then
            Tween(Data.Icon, 0.14, {
                ImageColor3 = Selected and Accent or MutedText
            })
        end
    end
end

SelectMode("Ragebot")
SelectPage("Combat")

Bind(RagebotMode.MouseButton1Click:Connect(function()
    SelectMode("Ragebot")
end))

Bind(LegitbotMode.MouseButton1Click:Connect(function()
    SelectMode("Legitbot")
end))

for Name, Data in pairs(Menu.SidebarButtons) do
    Bind(Data.Button.MouseButton1Click:Connect(function()
        SelectPage(Name)
    end))
    Bind(Data.Button.MouseEnter:Connect(function()
        if CurrentPage ~= Name then
            Tween(Data.Button, 0.12, {
                BackgroundTransparency = 0.5,
                BackgroundColor3 = Color3.fromRGB(22, 24, 35)
            })
        end
    end))
    Bind(Data.Button.MouseLeave:Connect(function()
        if CurrentPage ~= Name then
            Tween(Data.Button, 0.12, {
                BackgroundTransparency = 1,
                BackgroundColor3 = SidebarColor
            })
        end
    end))
end

Bind(SearchSettings.MouseButton1Click:Connect(function()
    if Menu.ToggleSettingsPanel then
        Menu.ToggleSettingsPanel()
    end
end))

Bind(SaveButton.MouseButton1Click:Connect(function()
    SavedPositions.Main = EncodePosition(Main.Position)
    SavedPositions.Settings = EncodePosition(SettingsPanel.Position)
    SavedPositions.Watermark = EncodePosition(Watermark.Position)
    SavedPositions.ColorPickerOffsetX = ColorPickerContainer.AbsolutePosition.X - SettingsPanel.AbsolutePosition.X
    SavedPositions.ColorPickerOffsetY = ColorPickerContainer.AbsolutePosition.Y - SettingsPanel.AbsolutePosition.Y
    SavedPositions.ColorPickerPinned = SavedPositions.ColorPickerPinned == true
    SavePositions()
    SaveButton.Text = "Saved"
    Tween(SaveButton, 0.12, {
        TextColor3 = Accent
    })
    task.delay(0.7, function()
        if SaveButton.Parent then
            SaveButton.Text = "Save"
            Tween(SaveButton, 0.15, {
                TextColor3 = PrimaryText
            })
        end
    end)
end))

Bind(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local Query = string.lower(SearchBox.Text)
    for _, Section in pairs(Menu.Sections) do
        local VisibleCount = 0
        for _, Control in ipairs(Section.Controls) do
            local Visible = Query == "" or string.find(Control.Name, Query, 1, true) ~= nil
            Control.Row.Visible = Visible
            if Visible then
                VisibleCount += 1
            end
        end
        Section.Root.Visible = Query == "" or VisibleCount > 0
    end
end))

local Dragging = false
local DragStart
local StartPosition
local SettingsDragging = false
local SettingsDragStart
local SettingsStartPosition
local ColorPickerWindowDragging = false
local ColorPickerWindowDragStart
local ColorPickerWindowStartPosition

Bind(SettingsDragArea.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        SetTextInputsEnabled(false)
        SettingsDragging = true
        SettingsDragStart = Input.Position
        SettingsStartPosition = SettingsPanel.Position
    end
end))

Bind(ColorPickerDragArea.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        SetTextInputsEnabled(false)
        ColorPickerWindowDragging = true
        ColorPickerWindowDragStart = Input.Position
        ColorPickerWindowStartPosition = ColorPickerContainer.Position
    end
end))

Bind(DragArea.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        SetTextInputsEnabled(false)
        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
    end
end))

local function ClampCenteredPosition(Object, Position)
    local Camera = workspace.CurrentCamera
    if not Camera then
        return Position
    end

    local Viewport = Camera.ViewportSize
    local ParentObject = Object.Parent
    local ParentPosition = ParentObject and ParentObject.AbsolutePosition or Vector2.new(0, 0)
    local ParentSize = ParentObject and ParentObject.AbsoluteSize or Viewport
    local Size = Object.AbsoluteSize
    local Anchor = Object.AnchorPoint
    local AbsoluteX = ParentPosition.X + (ParentSize.X * Position.X.Scale) + Position.X.Offset
    local AbsoluteY = ParentPosition.Y + (ParentSize.Y * Position.Y.Scale) + Position.Y.Offset
    local MinimumX = 16 + (Size.X * Anchor.X)
    local MaximumX = Viewport.X - 16 - (Size.X * (1 - Anchor.X))
    local MinimumY = 16 + (Size.Y * Anchor.Y)
    local MaximumY = Viewport.Y - 16 - (Size.Y * (1 - Anchor.Y))

    AbsoluteX = math.clamp(AbsoluteX, MinimumX, math.max(MinimumX, MaximumX))
    AbsoluteY = math.clamp(AbsoluteY, MinimumY, math.max(MinimumY, MaximumY))

    return UDim2.new(
        0,
        math.floor((AbsoluteX - ParentPosition.X) + 0.5),
        0,
        math.floor((AbsoluteY - ParentPosition.Y) + 0.5)
    )
end

Bind(UserInputService.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseMovement then
        if Dragging then
            local Delta = Input.Position - DragStart
            Main.Position = ClampCenteredPosition(Main, UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            ))
        end
        if SettingsDragging then
            local Delta = Input.Position - SettingsDragStart
            SettingsPanel.Position = ClampCenteredPosition(SettingsPanel, UDim2.new(
                SettingsStartPosition.X.Scale,
                SettingsStartPosition.X.Offset + Delta.X,
                SettingsStartPosition.Y.Scale,
                SettingsStartPosition.Y.Offset + Delta.Y
            ))
        end
        if ColorPickerWindowDragging then
            local Delta = Input.Position - ColorPickerWindowDragStart
            ColorPickerContainer.Position = ClampCenteredPosition(ColorPickerContainer, UDim2.new(
                ColorPickerWindowStartPosition.X.Scale,
                ColorPickerWindowStartPosition.X.Offset + Delta.X,
                ColorPickerWindowStartPosition.Y.Scale,
                ColorPickerWindowStartPosition.Y.Offset + Delta.Y
            ))
        end
    end
end))

Bind(UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Dragging then
            SavedPositions.Main = EncodePosition(Main.Position)
            SavePositions()
        end
        if SettingsDragging then
            SavedPositions.Settings = EncodePosition(SettingsPanel.Position)
            SavePositions()
        end
        if ColorPickerWindowDragging then
            SavedPositions.ColorPickerOffsetX = ColorPickerContainer.AbsolutePosition.X - SettingsPanel.AbsolutePosition.X
            SavedPositions.ColorPickerOffsetY = ColorPickerContainer.AbsolutePosition.Y - SettingsPanel.AbsolutePosition.Y
            SavedPositions.ColorPickerPinned = true
            SavePositions()
        end
        Dragging = false
        SettingsDragging = false
        ColorPickerWindowDragging = false
        task.defer(function()
            SetTextInputsEnabled(true)
        end)
    end
end))

local function UpdateScale()
    local Camera = workspace.CurrentCamera
    if not Camera then
        return
    end
    local Viewport = Camera.ViewportSize
    Menu.Flags.ViewportScale = math.min(1, (Viewport.X - 20) / 744, (Viewport.Y - 20) / 610)
    MainScale.Scale = Menu.Flags.ViewportScale * BaseScaleFactor
end

UpdateScale()
Bind(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.defer(UpdateScale)
end))

if workspace.CurrentCamera then
    Bind(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale))
end

local AssemblyTargets = {
    Sidebar = Sidebar.Position,
    Topbar = Topbar.Position,
    SearchBar = SearchBar.Position,
    SearchSettings = SearchSettings.Position
}

local AssemblyScales = {}
local AssemblyGeneration = 0

for _, Section in pairs(Menu.Sections) do
    AssemblyTargets[Section.Root] = Section.Root.Position
    local SectionScale = Create("UIScale", {
        Parent = Section.Root,
        Scale = 1
    })
    AssemblyScales[Section.Root] = SectionScale
    Section.AssemblyScale = SectionScale
end

local function AssemblyTween(Object, Duration, Properties, Style, Direction)
    local Animation = TweenService:Create(
        Object,
        TweenInfo.new(
            (Duration or 0.2) / math.max(AnimationFactor, 0.05),
            Style or Enum.EasingStyle.Quart,
            Direction or Enum.EasingDirection.Out
        ),
        Properties
    )
    Animation:Play()
    return Animation
end

local function OffsetPosition(Position, X, Y)
    return UDim2.new(
        Position.X.Scale,
        Position.X.Offset + X,
        Position.Y.Scale,
        Position.Y.Offset + Y
    )
end

local function PrepareAssembly()
    Sidebar.Position = OffsetPosition(AssemblyTargets.Sidebar, -118, 0)
    Topbar.Position = OffsetPosition(AssemblyTargets.Topbar, 0, -72)
    SearchBar.Position = OffsetPosition(AssemblyTargets.SearchBar, 72, 0)
    SearchSettings.Position = OffsetPosition(AssemblyTargets.SearchSettings, 42, 0)

    local Index = 0
    for _, Section in pairs(Menu.Sections) do
        local Root = Section.Root
        local Target = AssemblyTargets[Root] or Section.HomePosition or Root.Position
        AssemblyTargets[Root] = Target
        local SectionScale = AssemblyScales[Root]
        if not SectionScale or not SectionScale.Parent then
            SectionScale = Create("UIScale", {
                Parent = Root,
                Scale = 1
            })
            AssemblyScales[Root] = SectionScale
            Section.AssemblyScale = SectionScale
        end
        local IsRight = Target.X.Offset > 0
        local IsBottom = Target.Y.Offset > 0
        local XOffset = IsRight and 76 or -76
        local YOffset = IsBottom and 58 or -34
        Root.Position = OffsetPosition(Target, XOffset, YOffset)
        SectionScale.Scale = 0.88
        Index += 1
    end
end

local function AnimateAssemblyOpen(Generation)
    local TargetScale = (Menu.Flags.ViewportScale or 1) * BaseScaleFactor
    Main.Position = DecodePosition(SavedPositions.Main, Main.Position)
    Main.Visible = true
    InputBlocker.Visible = true
    Overlay.Visible = Menu.Flags.BackgroundDim ~= false
    MainScale.Scale = TargetScale * 0.91
    Main.BackgroundTransparency = 0.18
    Overlay.BackgroundTransparency = 1
    PrepareAssembly()

    local CurrentSelectedPage = Menu.Pages[CurrentPage]
    if CurrentSelectedPage then
        for _, Section in pairs(Menu.Sections) do
            if Section.Root.Parent ~= CurrentSelectedPage then
                Section.Root.Position = Section.HomePosition or AssemblyTargets[Section.Root] or Section.Root.Position
                local HiddenScale = Section.AssemblyScale
                if HiddenScale then
                    HiddenScale.Scale = 1
                end
            end
        end
    end

    AssemblyTween(Overlay, 0.24, {BackgroundTransparency = 0.55}, Enum.EasingStyle.Quad)
    AssemblyTween(MainScale, 0.36, {Scale = TargetScale}, Enum.EasingStyle.Back)
    AssemblyTween(Main, 0.24, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad)

    task.delay(0.035 / math.max(AnimationFactor, 0.05), function()
        if AssemblyGeneration ~= Generation or not Menu.Visible then
            return
        end
        AssemblyTween(Sidebar, 0.32, {Position = AssemblyTargets.Sidebar}, Enum.EasingStyle.Back)
    end)

    task.delay(0.085 / math.max(AnimationFactor, 0.05), function()
        if AssemblyGeneration ~= Generation or not Menu.Visible then
            return
        end
        AssemblyTween(Topbar, 0.30, {Position = AssemblyTargets.Topbar}, Enum.EasingStyle.Back)
    end)

    task.delay(0.135 / math.max(AnimationFactor, 0.05), function()
        if AssemblyGeneration ~= Generation or not Menu.Visible then
            return
        end
        AssemblyTween(SearchBar, 0.28, {Position = AssemblyTargets.SearchBar}, Enum.EasingStyle.Back)
        AssemblyTween(SearchSettings, 0.28, {Position = AssemblyTargets.SearchSettings}, Enum.EasingStyle.Back)
    end)

    local VisibleSections = {}
    for _, Section in pairs(Menu.Sections) do
        if Section.Root.Parent.Visible then
            table.insert(VisibleSections, Section.Root)
        end
    end
    table.sort(VisibleSections, function(A, B)
        local AP = AssemblyTargets[A] or A.Position
        local BP = AssemblyTargets[B] or B.Position
        if AP.Y.Offset == BP.Y.Offset then
            return AP.X.Offset < BP.X.Offset
        end
        return AP.Y.Offset < BP.Y.Offset
    end)

    for Index, Root in ipairs(VisibleSections) do
        task.delay((0.18 + ((Index - 1) * 0.055)) / math.max(AnimationFactor, 0.05), function()
            if AssemblyGeneration ~= Generation or not Menu.Visible then
                return
            end
            AssemblyTween(Root, 0.34, {Position = AssemblyTargets[Root] or Root.Position}, Enum.EasingStyle.Back)
            local SectionScale = AssemblyScales[Root]
            if SectionScale then
                AssemblyTween(SectionScale, 0.34, {Scale = 1}, Enum.EasingStyle.Back)
            end
        end)
    end
end

local function AnimateAssemblyClose(Generation)
    SavedPositions.Main = EncodePosition(Main.Position)
    SavedPositions.Settings = EncodePosition(SettingsPanel.Position)
    SavedPositions.Watermark = EncodePosition(Watermark.Position)
    SavedPositions.ColorPickerOffsetX = ColorPickerContainer.AbsolutePosition.X - SettingsPanel.AbsolutePosition.X
    SavedPositions.ColorPickerOffsetY = ColorPickerContainer.AbsolutePosition.Y - SettingsPanel.AbsolutePosition.Y
    SavePositions()
    ClosePopup()
    if CloseGearMenus then
        CloseGearMenus()
    end
    SetSettingsOpen(false)
    SetPickerOpen(false)

    local TargetScale = (Menu.Flags.ViewportScale or 1) * BaseScaleFactor
    local VisibleSections = {}
    for _, Section in pairs(Menu.Sections) do
        if Section.Root.Parent.Visible then
            table.insert(VisibleSections, Section.Root)
        end
    end

    for Index, Root in ipairs(VisibleSections) do
        local Target = AssemblyTargets[Root] or Root.Position
        AssemblyTargets[Root] = Target
        local IsRight = Target.X.Offset > 0
        local IsBottom = Target.Y.Offset > 0
        local XOffset = IsRight and 54 or -54
        local YOffset = IsBottom and 42 or -28
        task.delay(((Index - 1) * 0.018) / math.max(AnimationFactor, 0.05), function()
            if AssemblyGeneration ~= Generation or Menu.Visible then
                return
            end
            AssemblyTween(Root, 0.20, {Position = OffsetPosition(Target, XOffset, YOffset)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            local SectionScale = AssemblyScales[Root]
            if SectionScale then
                AssemblyTween(SectionScale, 0.20, {Scale = 0.9}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            end
        end)
    end

    AssemblyTween(SearchBar, 0.20, {Position = OffsetPosition(AssemblyTargets.SearchBar, 54, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    AssemblyTween(SearchSettings, 0.20, {Position = OffsetPosition(AssemblyTargets.SearchSettings, 38, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    AssemblyTween(Topbar, 0.22, {Position = OffsetPosition(AssemblyTargets.Topbar, 0, -58)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    AssemblyTween(Sidebar, 0.24, {Position = OffsetPosition(AssemblyTargets.Sidebar, -100, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    AssemblyTween(MainScale, 0.25, {Scale = TargetScale * 0.93}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    AssemblyTween(Main, 0.22, {BackgroundTransparency = 0.12}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    AssemblyTween(Overlay, 0.25, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    task.delay(0.27 / math.max(AnimationFactor, 0.05), function()
        if AssemblyGeneration ~= Generation or Menu.Visible then
            return
        end
        Main.Visible = false
        Overlay.Visible = false
        InputBlocker.Visible = false
    end)
end

local function SetVisible(State)
    State = State and true or false
    if Menu.Visible == State and Main.Visible == State then
        return
    end

    AssemblyGeneration += 1
    local Generation = AssemblyGeneration
    Menu.Visible = State

    if State then
        AnimateAssemblyOpen(Generation)
    else
        AnimateAssemblyClose(Generation)
    end
end

Menu.BindSystem.CaptureInput = function(Input)
    if not PendingBindCapture then
        return false
    end
    if Input.UserInputType == Enum.UserInputType.Keyboard and Menu.BindSystem.IsModifierKey(Input.KeyCode) then
        return true
    end
    local KeyType, KeyName = Menu.BindSystem.GetInputIdentity(Input)
    if not KeyType then
        return true
    end

    local Meta = PendingBindCapture.Meta
    local Modifiers = Menu.BindSystem.ReadModifiers()
    local Binds = Menu.BindSystem.GetControlBinds(Meta and Meta.Flag)
    local CapturedValue = Menu.Flags[Meta.Flag]
    local CapturedShowInBinds = true
    if PendingBindCapture.Value then
        CapturedValue = PendingBindCapture.Value()
    end
    if PendingBindCapture.ShowInBinds then
        CapturedShowInBinds = PendingBindCapture.ShowInBinds()
    end
    local BindData = {
        Id = tostring(os.clock()) .. tostring(math.random(1000, 9999)),
        KeyType = KeyType,
        Key = KeyName,
        Modifiers = Modifiers,
        Display = Menu.BindSystem.BuildBindDisplay(KeyName, Modifiers),
        Mode = PendingBindCapture.Mode and PendingBindCapture.Mode() or "Toggle",
        ShowInBinds = CapturedShowInBinds,
        Value = CapturedValue,
        BaseValue = Menu.Flags[Meta.Flag]
    }
    table.insert(Binds, BindData)
    SavePositions()
    if PendingBindCapture.SetText then
        PendingBindCapture.SetText(BindData.Display)
    end
    PendingBindCapture = nil
    return true
end

Menu.BindSystem.ExecutePressed = function(Flag, BindData)
    local Current = Menu.Flags[Flag]
    local Target = BindData.Value
    if BindData.Mode == "Hold" then
        local RuntimeKey = BindData.Id or (tostring(Flag) .. ":" .. tostring(BindData.Display or BindData.Key or ""))
        if Menu.BindRuntime[RuntimeKey] == nil then
            Menu.BindRuntime[RuntimeKey] = Current
            Menu.BindSystem.ApplyFlagValue(Flag, Target)
        end
        return
    end

    if type(Target) == "boolean" then
        Menu.BindSystem.ApplyFlagValue(Flag, Current == Target and not Target or Target)
    else
        local BaseValue = BindData.BaseValue
        if BaseValue == nil then
            BaseValue = Current
        end
        Menu.BindSystem.ApplyFlagValue(Flag, Current == Target and BaseValue or Target)
    end
end

Menu.BindSystem.ProcessBegan = function(Input)
    local AllBinds = SavedPositions.ControlBinds or {}
    for Flag, Binds in pairs(AllBinds) do
        if type(Binds) == "table" then
            for _, BindData in ipairs(Binds) do
                if Menu.BindSystem.BindMatchesInput(BindData, Input, true) then
                    Menu.BindSystem.ExecutePressed(Flag, BindData)
                end
            end
        end
    end
end

Menu.BindSystem.ProcessEnded = function(Input)
    local AllBinds = SavedPositions.ControlBinds or {}
    for Flag, Binds in pairs(AllBinds) do
        if type(Binds) == "table" then
            for _, BindData in ipairs(Binds) do
                local RuntimeKey = BindData.Id or (tostring(Flag) .. ":" .. tostring(BindData.Display or BindData.Key or ""))
                if BindData.Mode == "Hold" and Menu.BindRuntime[RuntimeKey] ~= nil and Menu.BindSystem.BindMatchesInput(BindData, Input, false) then
                    local Previous = Menu.BindRuntime[RuntimeKey]
                    Menu.BindRuntime[RuntimeKey] = nil
                    Menu.BindSystem.ApplyFlagValue(Flag, Previous)
                end
            end
        end
    end
end

Bind(UserInputService.InputBegan:Connect(function(Input, Processed)
    if PendingBindCapture then
        if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode.Escape then
            if PendingBindCapture.SetText then
                PendingBindCapture.SetText("Click to bind")
            end
            PendingBindCapture = nil
            return
        end
        if Menu.BindSystem.CaptureInput(Input) then
            return
        end
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        local Position = Input.Position
        local function IsInside(Object)
            if not Object or not Object.Parent then
                return false
            end
            local ObjectPosition = Object.AbsolutePosition
            local ObjectSize = Object.AbsoluteSize
            return Position.X >= ObjectPosition.X and Position.X <= ObjectPosition.X + ObjectSize.X
                and Position.Y >= ObjectPosition.Y and Position.Y <= ObjectPosition.Y + ObjectSize.Y
        end

        if ActiveGearMenu
            and not IsInside(ActiveGearMenu)
            and not IsInside(ActiveGearBindMenu)
            and not IsInside(ActiveGearHotkeysMenu)
            and not IsInside(ActiveGearButton) then
            CloseGearMenus()
        end

        if ActivePopup and not IsInside(ActivePopup) then
            ClosePopup()
        end
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton1 and PickerOpen and ColorPickerContainer.Visible then
        local Position = Input.Position
        local PickerPosition = ColorPickerContainer.AbsolutePosition
        local PickerSize = ColorPickerContainer.AbsoluteSize
        local SwatchPosition = AccentPreviewButton.AbsolutePosition
        local SwatchSize = AccentPreviewButton.AbsoluteSize
        local InsidePicker = Position.X >= PickerPosition.X and Position.X <= PickerPosition.X + PickerSize.X
            and Position.Y >= PickerPosition.Y and Position.Y <= PickerPosition.Y + PickerSize.Y
        local InsideSwatch = Position.X >= SwatchPosition.X and Position.X <= SwatchPosition.X + SwatchSize.X
            and Position.Y >= SwatchPosition.Y and Position.Y <= SwatchPosition.Y + SwatchSize.Y
        if not InsidePicker and not InsideSwatch then
            SetPickerOpen(false)
        end
    end

    if Processed then
        return
    end

    Menu.BindSystem.ProcessBegan(Input)

    if Input.KeyCode == Enum.KeyCode.F2 then
        SetVisible(not Menu.Visible)
    end
end))

Bind(UserInputService.InputEnded:Connect(function(Input)
    Menu.BindSystem.ProcessEnded(Input)
end))

Menu.Visible = false
Main.Visible = false
Overlay.Visible = false

task.defer(function()
    RunService.RenderStepped:Wait()
    SetVisible(true)
end)

function Menu:SetVisible(State)
    SetVisible(State)
end

function Menu:Toggle()
    SetVisible(not self.Visible)
end

function Menu:GetFlag(Name)
    return self.Flags[Name]
end

function Menu:Destroy()
    for _, Connection in ipairs(self.Connections) do
        pcall(function()
            Connection:Disconnect()
        end)
    end
    table.clear(self.Connections)
    ScreenGui:Destroy()
end


function Menu:InstallPublicApi()
local Library = self
local ApiState = {Initialized = false, PageSlots = {}, Keybinds = {}}
ApiState.PageOrder = {"Combat", "Visuals", "Movement", "World", "Utility", "Settings", "Players", "Cloud", "Config", "Misc"}
ApiState.PageIcons = {
    Combat = "Pistol",
    Visuals = "Minus",
    Movement = "Shield",
    World = "Cloud",
    Utility = "Gear",
    Settings = "Gear",
    Players = "Target",
    Cloud = "Cloud",
    Config = "Gear",
    Misc = "Shield"
}
ApiState.WindowObject = nil

local function ApiRead(Data, Name, Fallback)
    if type(Data) ~= "table" then
        return Fallback
    end
    local Value = Data[Name]
    if Value == nil then
        Value = Data[string.lower(Name)]
    end
    if Value == nil then
        return Fallback
    end
    return Value
end

local function ApiNormalizeFlag(Data, Name)
    return tostring(ApiRead(Data, "Flag", Name) or Name)
end

local function ApiClearBuiltInContent()
    if ApiState.Initialized then
        return
    end
    ApiState.Initialized = true
    for _, Section in pairs(Menu.Sections) do
        if Section.Root and Section.Root.Parent then
            Section.Root:Destroy()
        end
    end
    table.clear(Menu.Sections)
    table.clear(Menu.Flags)
    table.clear(Menu.Setters)
end

local function ApiEnsureSidebarPage(Name)
    local Existing = Menu.SidebarButtons[Name]
    if Existing then
        return Existing
    end
    local Count = 0
    for _ in pairs(Menu.SidebarButtons) do
        Count += 1
    end
    local Y = 116 + (Count * 58)
    if Y > 548 then
        Y = 116 + ((Count % 8) * 58)
    end
    local Button = Create("TextButton", {
        Parent = Sidebar,
        Position = UDim2.fromOffset(28, Y),
        Size = UDim2.fromOffset(54, 48),
        BackgroundColor3 = SidebarColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 5
    })
    Corner(Button, 10)
    local Marker = Create("Frame", {
        Parent = Sidebar,
        Position = UDim2.fromOffset(0, Y + 10),
        Size = UDim2.fromOffset(2, 28),
        BackgroundColor3 = Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 7
    })
    Corner(Marker, 2)
    local IconObject = Icon(Button, ApiState.PageIcons[Name] or "Gear", UDim2.fromOffset(20, 20), UDim2.fromScale(0.5, 0.5), MutedText, 7)
    Existing = {Button = Button, Marker = Marker, Icon = IconObject}
    Menu.SidebarButtons[Name] = Existing
    Bind(Button.MouseButton1Click:Connect(function()
        SelectPage(Name)
    end))
    return Existing
end

local function ApiGetPage(Name)
    local Page = Menu.Pages[Name]
    if not Page then
        Page = CreatePage(Name)
    end
    ApiEnsureSidebarPage(Name)
    if not ApiState.PageSlots[Name] then
        ApiState.PageSlots[Name] = {Left = 0, Right = 0, SubPages = {}, CurrentSubPage = nil}
    end
    return Page, ApiState.PageSlots[Name]
end

local function ApiCreateLabel(Section, Data)
    local Name = tostring(ApiRead(Data, "Name", "Label"))
    local Row = CreateRow(Section.Body, 24)
    local Label = Create("TextLabel", {
        Parent = Row,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.BuilderSans,
        Text = Name,
        TextColor3 = PrimaryText,
        TextSize = 11,
        TextXAlignment = ApiRead(Data, "Alignment", "Left") == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
        ZIndex = 8
    })
    RegisterControl(Section, Row, Name)
    local Object = {Row = Row, Label = Label}
    function Object:Set(Value)
        Label.Text = tostring(Value)
    end
    function Object:Colorpicker(ColorData)
        return ApiCreateColorpicker(Section, ColorData, Row)
    end
    function Object:Keybind(KeyData)
        return ApiCreateKeybind(Section, KeyData, Row)
    end
    return Object
end

function ApiCreateColorpicker(Section, Data, ExistingRow)
    Data = Data or {}
    local Name = tostring(ApiRead(Data, "Name", "Color"))
    local Flag = ApiNormalizeFlag(Data, Name)
    local Default = ApiRead(Data, "Default", Accent)
    local Callback = ApiRead(Data, "Callback")
    local Row = ExistingRow or CreateRow(Section.Body, 27)
    if not ExistingRow then
        Create("TextLabel", {
            Parent = Row,
            Size = UDim2.new(1, -44, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.BuilderSans,
            Text = Name,
            TextColor3 = PrimaryText,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8
        })
        RegisterControl(Section, Row, Name)
    end
    local Button = Create("TextButton", {
        Parent = Row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(30, 16),
        BackgroundColor3 = typeof(Default) == "Color3" and Default or Accent,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 9
    })
    Corner(Button, 4)
    local BorderStroke = Stroke(Button, Border, 0.08, 1)
    local Value = typeof(Default) == "Color3" and Default or Accent
    Menu.Flags[Flag] = Value
    local Object = {}
    function Object:Set(NewValue)
        if typeof(NewValue) ~= "Color3" then
            return
        end
        Value = NewValue
        Menu.Flags[Flag] = NewValue
        Button.BackgroundColor3 = NewValue
        if type(Callback) == "function" then
            task.spawn(Callback, NewValue)
        end
    end
    function Object:Get()
        return Value
    end
    Menu.Setters[Flag] = Object.Set
    Bind(Button.MouseButton1Click:Connect(function()
        local H, S, V = Value:ToHSV()
        H = (H + 0.0833333333) % 1
        Object:Set(Color3.fromHSV(H, math.max(S, 0.55), math.max(V, 0.75)))
        Tween(BorderStroke, 0.12, {Color = Value})
    end))
    return Object
end

function ApiCreateKeybind(Section, Data, ExistingRow)
    Data = Data or {}
    local Name = tostring(ApiRead(Data, "Name", "Keybind"))
    local Flag = ApiNormalizeFlag(Data, Name)
    local Default = ApiRead(Data, "Default", "None")
    local Mode = tostring(ApiRead(Data, "Mode", "Toggle"))
    local Callback = ApiRead(Data, "Callback")
    local Row = ExistingRow or CreateRow(Section.Body, 27)
    if not ExistingRow then
        Create("TextLabel", {
            Parent = Row,
            Size = UDim2.new(1, -90, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.BuilderSans,
            Text = Name,
            TextColor3 = PrimaryText,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8
        })
        RegisterControl(Section, Row, Name)
    end
    local Button = Create("TextButton", {
        Parent = Row,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(76, 22),
        BackgroundColor3 = SurfaceAlt,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.BuilderSansMedium,
        Text = tostring(Default),
        TextColor3 = MutedText,
        TextSize = 10,
        ZIndex = 9
    })
    Corner(Button, 5)
    Stroke(Button, Border, 0.2, 1)
    local Capturing = false
    local Current = Default
    local Active = false
    local Object = {}
    function Object:Set(Value)
        Current = Value
        Menu.Flags[Flag] = Value
        Button.Text = typeof(Value) == "EnumItem" and Value.Name or tostring(Value)
    end
    function Object:Get()
        return Current
    end
    Menu.Flags[Flag] = Current
    Menu.Setters[Flag] = Object.Set
    ApiState.Keybinds[Flag] = {Object = Object, Mode = Mode, Callback = Callback, Active = false}
    Bind(Button.MouseButton1Click:Connect(function()
        Capturing = true
        Button.Text = "..."
    end))
    Bind(UserInputService.InputBegan:Connect(function(Input, Processed)
        if Capturing then
            if Input.UserInputType == Enum.UserInputType.Keyboard then
                Capturing = false
                Object:Set(Input.KeyCode)
            elseif Input.UserInputType.Name:find("MouseButton") then
                Capturing = false
                Object:Set(Input.UserInputType)
            end
            return
        end
        if Processed then
            return
        end
        local Match = Current == Input.KeyCode or Current == Input.UserInputType
        if not Match then
            return
        end
        if Mode == "Hold" then
            Active = true
            if type(Callback) == "function" then
                task.spawn(Callback, true)
            end
        else
            Active = not Active
            if type(Callback) == "function" then
                task.spawn(Callback, Active)
            end
        end
    end))
    Bind(UserInputService.InputEnded:Connect(function(Input)
        if Mode ~= "Hold" or not Active then
            return
        end
        if Current == Input.KeyCode or Current == Input.UserInputType then
            Active = false
            if type(Callback) == "function" then
                task.spawn(Callback, false)
            end
        end
    end))
    return Object
end

local ApiSectionMethods = {}
ApiSectionMethods.__index = ApiSectionMethods

function ApiSectionMethods:Toggle(Data)
    Data = Data or {}
    local Control = CreateToggle(self.Section, tostring(ApiRead(Data, "Name", "Toggle")), ApiRead(Data, "Default", false), ApiNormalizeFlag(Data, ApiRead(Data, "Name", "Toggle")), {
        Gear = ApiRead(Data, "Gear", false),
        Warning = ApiRead(Data, "Warning", false),
        Disabled = ApiRead(Data, "Disabled", false),
        Callback = ApiRead(Data, "Callback")
    })
    function Control:Keybind(KeyData)
        ApiCreateKeybind(self._Section or self.Section or self, KeyData)
        return self
    end
    function Control:Colorpicker(ColorData)
        ApiCreateColorpicker(self._Section or self.Section or self, ColorData)
        return self
    end
    Control._Section = self.Section
    return Control
end

function ApiSectionMethods:Slider(Data)
    Data = Data or {}
    local Decimals = ApiRead(Data, "Decimals")
    if type(Decimals) == "number" and Decimals > 0 and Decimals < 1 then
        Decimals = math.max(0, math.floor(-math.log10(Decimals) + 0.5))
    end
    return CreateSlider(self.Section, tostring(ApiRead(Data, "Name", "Slider")), tonumber(ApiRead(Data, "Min", 0)) or 0, tonumber(ApiRead(Data, "Max", 100)) or 100, tonumber(ApiRead(Data, "Default", 0)) or 0, ApiNormalizeFlag(Data, ApiRead(Data, "Name", "Slider")), {
        Decimals = Decimals,
        Suffix = ApiRead(Data, "Suffix", ""),
        Box = ApiRead(Data, "Box", true),
        Gear = ApiRead(Data, "Gear", false),
        Disabled = ApiRead(Data, "Disabled", false),
        Callback = ApiRead(Data, "Callback")
    })
end

function ApiSectionMethods:Dropdown(Data)
    Data = Data or {}
    return CreateDropdown(self.Section, tostring(ApiRead(Data, "Name", "Dropdown")), ApiRead(Data, "Items", ApiRead(Data, "Values", {})), ApiRead(Data, "Default"), ApiNormalizeFlag(Data, ApiRead(Data, "Name", "Dropdown")), {
        Gear = ApiRead(Data, "Gear", false),
        Disabled = ApiRead(Data, "Disabled", false),
        Callback = ApiRead(Data, "Callback")
    })
end

function ApiSectionMethods:Label(Data)
    return ApiCreateLabel(self.Section, Data or {})
end

function ApiSectionMethods:Colorpicker(Data)
    return ApiCreateColorpicker(self.Section, Data or {})
end

function ApiSectionMethods:Keybind(Data)
    return ApiCreateKeybind(self.Section, Data or {})
end

local ApiSubPageMethods = {}
ApiSubPageMethods.__index = ApiSubPageMethods

function ApiSubPageMethods:Section(Data)
    Data = Data or {}
    local Side = tonumber(ApiRead(Data, "Side", 1)) == 2 and "Right" or "Left"
    local Slot = self.Slots[Side]
    local X = Side == "Right" and 320 or 0
    local Height = tonumber(ApiRead(Data, "Height", 220)) or 220
    local Position = UDim2.fromOffset(X, Slot)
    local Size = UDim2.fromOffset(Side == "Right" and 302 or 306, Height)
    self.Slots[Side] = Slot + Height + 12
    local Key = self.PageName .. ":" .. self.Name .. ":" .. tostring(ApiRead(Data, "Name", "Section")) .. ":" .. Side .. ":" .. tostring(Slot)
    local Section = CreateSection(self.Frame, Key, tostring(ApiRead(Data, "Name", "Section")), Position, Size)
    return setmetatable({Section = Section}, ApiSectionMethods)
end

local ApiPageMethods = {}
ApiPageMethods.__index = ApiPageMethods

function ApiPageMethods:SubPage(Data)
    Data = Data or {}
    local Name = tostring(ApiRead(Data, "Name", "General"))
    local Existing = self.SubPages[Name]
    if Existing then
        return Existing
    end
    local Frame = Create("Frame", {
        Parent = self.Frame,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = next(self.SubPages) == nil,
        ZIndex = 4
    })
    local Object = setmetatable({Name = Name, PageName = self.Name, Frame = Frame, Slots = {Left = 0, Right = 0}}, ApiSubPageMethods)
    self.SubPages[Name] = Object
    if not self.FirstSubPage then
        self.FirstSubPage = Object
    end
    return Object
end

function ApiPageMethods:Section(Data)
    if not self.FirstSubPage then
        self:SubPage({Name = "General"})
    end
    return self.FirstSubPage:Section(Data)
end

local ApiWindowMethods = {}
ApiWindowMethods.__index = ApiWindowMethods

function ApiWindowMethods:Page(Data)
    Data = Data or {}
    local Name = tostring(ApiRead(Data, "Name", "Page"))
    if self.Pages[Name] then
        return self.Pages[Name]
    end
    local Frame = ApiGetPage(Name)
    local Object = setmetatable({Name = Name, Frame = Frame, SubPages = {}}, ApiPageMethods)
    self.Pages[Name] = Object
    if not self.FirstPage then
        self.FirstPage = Name
        SelectPage(Name)
    end
    return Object
end

function ApiWindowMethods:SetVisible(State)
    Library:SetVisible(State)
end

function ApiWindowMethods:Toggle()
    Library:Toggle()
end

function Library:Window(Data)
    ApiClearBuiltInContent()
    Data = Data or {}
    if ApiState.WindowObject then
        return ApiState.WindowObject
    end
    ApiState.WindowObject = setmetatable({Pages = {}}, ApiWindowMethods)
    local Name = tostring(ApiRead(Data, "Name", "Atramenta.rip"))
    for _, Object in ipairs(SettingsPanel:GetChildren()) do
        if Object:IsA("TextLabel") and Object.Text == "Atramenta.rip" then
            Object.Text = Name
        end
    end
    return ApiState.WindowObject
end

Library.window = Library.Window
ApiWindowMethods.page = ApiWindowMethods.Page
ApiPageMethods.subpage = ApiPageMethods.SubPage
ApiPageMethods.section = ApiPageMethods.Section
ApiSubPageMethods.section = ApiSubPageMethods.Section
ApiSectionMethods.toggle = ApiSectionMethods.Toggle
ApiSectionMethods.slider = ApiSectionMethods.Slider
ApiSectionMethods.dropdown = ApiSectionMethods.Dropdown
ApiSectionMethods.label = ApiSectionMethods.Label
ApiSectionMethods.colorpicker = ApiSectionMethods.Colorpicker
ApiSectionMethods.keybind = ApiSectionMethods.Keybind

function Library:Watermark()
    return {
        SetVisibility = function(_, State)
            if SetWatermarkHidden then
                SetWatermarkHidden(not State)
            end
        end,
        SetScale = function(_, Value)
            if SetWatermarkScale then
                SetWatermarkScale(Value)
            end
        end
    }
end

function Library:KeybindList()
    return {
        SetVisibility = function() end
    }
end

function Library:SetFlag(Name, Value)
    local Setter = self.Setters[Name]
    if type(Setter) == "function" then
        Setter(Value)
    else
        self.Flags[Name] = Value
    end
end

return Library
end

return Menu:InstallPublicApi()
